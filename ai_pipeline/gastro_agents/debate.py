"""Agent Debate — 3-iterasyonlu müzakere mantığı (Sprint 2, Görev 2).

Üç ajan-personası, Profiler/RAG/Optimizer cephelerini temsil eder ve aday mekanlar
üzerinde çatışma kurallarıyla (conflicts.py) müzakere eder:

  - DietGuardian   (Profiler cephesi): alerjen/sağlık -> KATI VETO
  - BudgetLogistics (Optimizer cephesi): bütçe -> veto/downrank
  - GourmetCritic  (RAG cephesi): lezzet/otantiklik -> yumuşak puan

3 tur, üç aşamalı bir protokoldür:
  Tur 1 (filtreleme): DietGuardian + BudgetLogistics katı vetolar
  Tur 2 (puanlama):   GourmetCritic lezzet puanı + BudgetLogistics hafif itiraz
  Tur 3 (uzlaşma):    Supervisor konsensüsü kesinleştirir ve onaylar

mock modda tamamen deterministiktir (LLM gerekmez); crew modunda (Sprint 2 gerçek
sağlayıcı) prompts/debate.py bu protokolü LLM'e anlatır.
"""
from __future__ import annotations

from .conflicts import check_allergen, check_budget, check_busyness, estimate_cost, taste_score
from .contracts import DebateRound, DebateTurn, TasteProfile, VenueCandidate


def _turn(rnd: int, persona: str, action: str, c: VenueCandidate, reason: str) -> DebateTurn:
    return DebateTurn(round=rnd, persona=persona, action=action, target_place_id=c.place_id, reason=reason)


def run_debate(
    candidates: list[VenueCandidate], profile: TasteProfile, rounds: int = 3
) -> tuple[list[VenueCandidate], list[DebateRound]]:
    """Adayları müzakereden geçirir. (hayatta_kalanlar, tur_kayıtları) döndürür."""
    survivors: list[VenueCandidate] = [c.model_copy(deep=True) for c in candidates]
    for c in survivors:
        if c.estimated_cost_per_person is None:
            c.estimated_cost_per_person = estimate_cost(c.price_level)
    log: list[DebateRound] = []

    # --- Tur 1: FİLTRELEME (katı veto) ---
    if rounds >= 1:
        turns: list[DebateTurn] = []
        dropped: list[str] = []
        kept: list[VenueCandidate] = []
        for c in survivors:
            bad = check_allergen(c, profile)
            if bad:
                turns.append(_turn(1, "DietGuardian", "veto", c, f"'{bad}' içerebilir — alerjen/hassasiyet kırmızı çizgisi"))
                dropped.append(c.place_id)
                continue
            verdict, cost = check_budget(c, profile)
            c.estimated_cost_per_person = cost
            if verdict == "veto":
                turns.append(_turn(1, "BudgetLogistics", "veto", c, f"~{cost}TL, bütçenin ({profile.budget_per_person}TL) 1.5 katını aşıyor"))
                dropped.append(c.place_id)
                continue
            kept.append(c)
        survivors = kept
        log.append(DebateRound(index=1, phase="filtreleme", turns=turns, dropped=dropped,
                               surviving=[c.place_id for c in survivors]))

    # --- Tur 2: PUANLAMA / İTİRAZ (yumuşak) ---
    if rounds >= 2:
        turns = []
        for c in survivors:
            ts = taste_score(c)
            c.consensus_score = ts
            turns.append(_turn(2, "GourmetCritic", "uprank" if ts >= 4.0 else "approve", c, f"lezzet/otantiklik puanı {ts}"))
            verdict, cost = check_budget(c, profile)
            if verdict == "downrank":
                c.consensus_score -= 1.5
                turns.append(_turn(2, "BudgetLogistics", "downrank", c, f"~{cost}TL bütçe üstü — puan kırıldı"))
            # Yoğunluk itirazı (konfor kısıtı — veto değil, puan kırar)
            busy_verdict, busyness = check_busyness(c)
            if busy_verdict == "downrank":
                c.consensus_score -= 1.0
                quiet = f", en sakin saat {c.quietest_hour}:00" if c.quietest_hour is not None else ""
                turns.append(_turn(2, "BudgetLogistics", "downrank", c,
                                   f"ziyaret saatinde yoğunluk %{int(busyness * 100)} — kalabalık{quiet}"))
        survivors.sort(key=lambda c: -c.consensus_score)
        log.append(DebateRound(index=2, phase="puanlama", turns=turns, dropped=[],
                               surviving=[c.place_id for c in survivors]))

    # --- Tur 3: UZLAŞMA (konsensüs) ---
    if rounds >= 3:
        turns = []
        for c in survivors:
            turns.append(_turn(3, "Supervisor", "approve", c, f"uzlaşı puanı {round(c.consensus_score, 3)} ile onaylandı"))
        before = [c.place_id for c in survivors]
        survivors.sort(key=lambda c: -c.consensus_score)
        converged = [c.place_id for c in survivors] == before
        log.append(DebateRound(index=3, phase="uzlasma", turns=turns, dropped=[],
                               surviving=[c.place_id for c in survivors], converged=converged))

    # --- İstenen tur sayısı 3'ten fazlaysa: ek uzlaşma turları (kararlı) ---
    for i in range(4, rounds + 1):
        log.append(DebateRound(index=i, phase="uzlasma", turns=[], dropped=[],
                               surviving=[c.place_id for c in survivors], converged=True))

    return survivors, log

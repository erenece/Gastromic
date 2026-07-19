"""Konsol demo: `python -m gastro_agents` (agents/ dizininden) veya
`python agents/run_demo.py` (repo kökünden).

Örnek kullanıcı tercihleriyle (tercih ekranını taklit eder) tüm ajan hattını
mock modda çalıştırır ve GastroData JSON'unu basar.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

# Paket kökünü (agents/) import yoluna ekle
sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from gastro_agents.contracts import DailyMode, UserPreferences  # noqa: E402
from gastro_agents.router import SupervisorRouter  # noqa: E402


def demo_prefs() -> UserPreferences:
    return UserPreferences(
        budget_per_person=500,
        city="İstanbul",
        allergens=["süt", "yumurta"],
        sensitivities=["laktoz intoleransı"],
        daily_mode=DailyMode.ORGANIK,
        smoking_area=False,
        alcohol_served=False,
    )


def main() -> None:
    prefs = demo_prefs()
    result = SupervisorRouter().run(prefs)
    print(json.dumps(result.model_dump(mode="json"), ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()

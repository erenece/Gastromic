"""Optimizer Agent tool: `tsp_route_solver` (Sprint 2, Görev 5).

Optimizer Agent'ı Üye 1'in TSP rota modülüne bağlar. Üye 1'in modülü henüz repoda
yoksa, aynı arayüzle bir nearest-neighbor fallback çalışır — böylece Optimizer
cephesi bugün de uçtan uca sonuç üretir, Üye 1 modülü gelince tek satırla devralır.

Üye 1'den BEKLENEN arayüz (Sprint 2 sözleşmesi):
    optimization.tsp.solve(points: list[tuple[str, float, float]]) -> list[str]
    # points = (place_id, lat, lng); dönüş = optimize sıralı place_id listesi
"""
from __future__ import annotations

import math

from ..contracts import GastroRoute, VenueCandidate


def _haversine(a: tuple[float, float], b: tuple[float, float]) -> float:
    """İki (lat, lng) arası büyük-çember mesafesi (km)."""
    radius = 6371.0
    lat1, lat2 = math.radians(a[0]), math.radians(b[0])
    dlat = math.radians(b[0] - a[0])
    dlng = math.radians(b[1] - a[1])
    h = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlng / 2) ** 2
    return 2 * radius * math.asin(math.sqrt(h))


def _try_member1_tsp(points: list[tuple[str, float, float]]) -> list[str] | None:
    """Üye 1'in TSP modülünü çağırmayı dener; yoksa/None ise None döner (fallback tetiklenir)."""
    try:
        from optimization.tsp import solve  # type: ignore
    except Exception:
        return None
    try:
        result = solve(points)
        return list(result) if result else None
    except Exception:
        return None


def _nearest_neighbor(points: list[tuple[str, float, float]], start: int = 0) -> tuple[list[str], float]:
    n = len(points)
    visited = [False] * n
    visited[start] = True
    order = [points[start][0]]
    cur = start
    total = 0.0
    for _ in range(n - 1):
        best, best_d = -1, None
        for j in range(n):
            if visited[j]:
                continue
            d = _haversine((points[cur][1], points[cur][2]), (points[j][1], points[j][2]))
            if best_d is None or d < best_d:
                best_d, best = d, j
        visited[best] = True
        order.append(points[best][0])
        total += best_d or 0.0
        cur = best
    return order, round(total, 2)


def solve_route(candidates: list[VenueCandidate]) -> GastroRoute:
    """Konumu olan adayları optimize rotaya dizer (Üye 1 modülü veya fallback)."""
    pts = [(c.place_id, c.location.lat, c.location.lng) for c in candidates if c.location]
    if len(pts) < 2:
        return GastroRoute(
            ordered_place_ids=[c.place_id for c in candidates],
            total_distance_km=0.0,
            solver="trivial",
        )

    id_to_geo = {c.place_id: (c.location.lat, c.location.lng) for c in candidates if c.location}

    ordered = _try_member1_tsp(pts)
    if ordered:
        total = sum(_haversine(id_to_geo[a], id_to_geo[b]) for a, b in zip(ordered, ordered[1:]))
        return GastroRoute(ordered_place_ids=ordered, total_distance_km=round(total, 2), solver="member1_tsp")

    order, total = _nearest_neighbor(pts)
    return GastroRoute(ordered_place_ids=order, total_distance_km=total, solver="nearest_neighbor_fallback")

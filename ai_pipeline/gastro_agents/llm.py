"""LLM fabrikası — AI beynini seçer, anahtar/SDK yoksa güvenle mock'a düşer.

Varsayılan sağlayıcı: gemini. GEMINI_API_KEY (veya GOOGLE_API_KEY) tanımlı ve
google-genai kurulu değilse otomatik olarak MockLLM'e düşülür — offline hiç kırılmaz.
"""
from __future__ import annotations

import os

from .config import LLM_MODEL, LLM_PROVIDER, THINKING_BUDGET
from .mock_llm import MockLLM


def build_llm(provider: str | None = None, model: str | None = None):
    provider = (provider or LLM_PROVIDER).lower()

    if provider == "gemini":
        api_key = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY")
        if not api_key:
            return MockLLM(note="GEMINI_API_KEY tanımlı değil — mock'a düşüldü")
        try:
            from .gemini_llm import GeminiLLM

            return GeminiLLM(
                model=model or LLM_MODEL or None,
                api_key=api_key,
                thinking_budget=THINKING_BUDGET,
            )
        except ImportError:
            return MockLLM(note="google-genai kurulu değil (pip install google-genai) — mock'a düşüldü")
        except Exception as exc:  # pragma: no cover - beklenmeyen istemci hatası
            return MockLLM(note=f"Gemini istemcisi kurulamadı ({type(exc).__name__}) — mock'a düşüldü")

    if provider == "openai":
        # Sprint 3: OpenAI adapteri eklenecek
        return MockLLM(note="openai adapteri henüz yok (Sprint 3) — mock'a düşüldü")

    return MockLLM()

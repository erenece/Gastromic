"""Offline, deterministik sahte LLM.

Gerçek sağlayıcı (Gemini/OpenAI) Sprint 2'de takılana kadar ajan hattının
API anahtarı OLMADAN uçtan uca çalışmasını sağlar. Gerçek bir çıkarım yapmaz;
sadece ajanların 'gerekçe' metnini simüle eder ve LLM bağlanacak yeri işaretler.
"""
from __future__ import annotations


class MockLLM:
    provider = "mock"
    model = "mock-deterministic-v0"

    def invoke(self, prompt: str, **kwargs) -> str:
        head = ""
        stripped = prompt.strip()
        if stripped:
            head = stripped.splitlines()[0][:80]
        return f"[mock-llm] görev alındı: {head}"

    # Bazı çağıranlar callable bekler; uyum için takma ad.
    def __call__(self, prompt: str, **kwargs) -> str:
        return self.invoke(prompt, **kwargs)

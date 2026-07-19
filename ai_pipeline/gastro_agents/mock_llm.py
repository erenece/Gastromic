"""Offline, deterministik sahte LLM (fallback beyin).

Gemini anahtarı/SDK'sı yokken ajan hattının API çağrısı YAPMADAN uçtan uca çalışmasını
sağlar. Gerçek çıkarım yapmaz; `note` neden mock'a düşüldüğünü taşır.
"""
from __future__ import annotations


class MockLLM:
    provider = "mock"
    model = "mock-deterministic-v0"

    def __init__(self, note: str | None = None):
        self.note = note

    def invoke(self, prompt: str, system: str | None = None, **kwargs) -> str:
        return "[mock-llm] " + (self.note or "offline — gerçek çıkarım yok")

    def __call__(self, prompt: str, **kwargs) -> str:
        return self.invoke(prompt, **kwargs)

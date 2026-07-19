"""AI beyni (LLM) sağlayıcı seçimi ve güvenli mock fallback testleri."""
from __future__ import annotations

from gastro_agents.llm import build_llm
from gastro_agents.mock_llm import MockLLM


def test_gemini_falls_back_to_mock_without_key(monkeypatch):
    monkeypatch.delenv("GEMINI_API_KEY", raising=False)
    monkeypatch.delenv("GOOGLE_API_KEY", raising=False)
    llm = build_llm("gemini")
    assert isinstance(llm, MockLLM)
    assert "GEMINI_API_KEY" in (llm.note or "")


def test_explicit_mock_provider():
    llm = build_llm("mock")
    assert llm.provider == "mock"


def test_openai_not_yet_supported_falls_back(monkeypatch):
    llm = build_llm("openai")
    assert isinstance(llm, MockLLM)
    assert "openai" in (llm.note or "").lower()


def test_gemini_used_when_key_present(monkeypatch):
    """Anahtar + google-genai varsa GeminiLLM seçilmeli; SDK yoksa test atlanır."""
    import importlib.util

    if importlib.util.find_spec("google.genai") is None:
        import pytest

        pytest.skip("google-genai kurulu değil")
    monkeypatch.setenv("GEMINI_API_KEY", "test-dummy-key")
    llm = build_llm("gemini")
    assert llm.provider == "gemini"
    assert llm.model  # model id atanmış olmalı

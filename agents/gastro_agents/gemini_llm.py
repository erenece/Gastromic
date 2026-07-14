"""Gemini LLM istemcisi (google-genai) — AI beyni.

Ajanların doğal-dil sentezini (GastroPass rehber metni, akıl yürütme) Gemini üretir.
Güvenlik-kritik mantık (alerjen vetosu, bütçe, TSP) deterministik katmanda kalır;
Gemini onların ürettiği yapılandırılmış sonucu doğal dile çevirir.

google-genai importu BİLEREK tembeldir (__init__ içinde) — böylece SDK kurulu
olmadan paket import edilebilir ve mock'a düşülebilir.
"""
from __future__ import annotations

DEFAULT_MODEL = "gemini-2.0-flash-001"


class GeminiLLM:
    provider = "gemini"

    def __init__(
        self,
        model: str | None = None,
        api_key: str | None = None,
        temperature: float = 0.4,
        max_output_tokens: int = 600,
    ):
        from google import genai  # lazy: SDK yoksa ImportError -> çağıran mock'a düşer

        self.model = model or DEFAULT_MODEL
        self.temperature = temperature
        self.max_output_tokens = max_output_tokens
        self.note = None
        self._client = genai.Client(api_key=api_key)

    def invoke(self, prompt: str, system: str | None = None, **kwargs) -> str:
        from google.genai import types

        response = self._client.models.generate_content(
            model=self.model,
            contents=prompt,
            config=types.GenerateContentConfig(
                system_instruction=system,
                temperature=self.temperature,
                max_output_tokens=self.max_output_tokens,
            ),
        )
        return (response.text or "").strip()

    def __call__(self, prompt: str, **kwargs) -> str:
        return self.invoke(prompt, **kwargs)

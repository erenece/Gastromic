"""Gemini LLM istemcisi (google-genai) — AI beyni.

Ajanların doğal-dil sentezini (GastroPass rehber metni) Gemini üretir.
Güvenlik-kritik mantık (alerjen vetosu, bütçe, TSP) deterministik katmanda kalır.

⚠️ THINKING BUDGET TUZAĞI: Güncel flash modelleri varsayılan olarak "thinking"
açık gelir ve gizli düşünme tokenleri max_output_tokens bütçesini yer. Ölçüldü:
600 token bütçenin 572'si (≈%93) thinking'e gitti, görünür metin 24 token'da
MAX_TOKENS ile kesildi. Bu yüzden thinking varsayılan olarak KAPALIDIR
(thinking_budget=0); GASTRO_THINKING_BUDGET ile açılabilir.

google-genai importu BİLEREK tembeldir (__init__ içinde) — SDK yoksa mock'a düşülür.
"""
from __future__ import annotations

DEFAULT_MODEL = "gemini-flash-latest"


class GeminiLLM:
    provider = "gemini"

    def __init__(
        self,
        model: str | None = None,
        api_key: str | None = None,
        temperature: float = 0.4,
        max_output_tokens: int = 800,
        thinking_budget: int | None = 0,
    ):
        from google import genai  # lazy: SDK yoksa ImportError -> çağıran mock'a düşer

        self.model = model or DEFAULT_MODEL
        self.temperature = temperature
        self.max_output_tokens = max_output_tokens
        self.thinking_budget = thinking_budget
        self.note = None
        self._client = genai.Client(api_key=api_key)

    def _config(self, system: str | None, with_thinking: bool):
        from google.genai import types

        kwargs = dict(
            system_instruction=system,
            temperature=self.temperature,
            max_output_tokens=self.max_output_tokens,
        )
        if with_thinking and self.thinking_budget is not None:
            kwargs["thinking_config"] = types.ThinkingConfig(thinking_budget=self.thinking_budget)
        return types.GenerateContentConfig(**kwargs)

    def invoke(self, prompt: str, system: str | None = None, **kwargs) -> str:
        try:
            response = self._client.models.generate_content(
                model=self.model, contents=prompt, config=self._config(system, True)
            )
        except Exception as exc:
            # Model thinking_config desteklemiyorsa thinking'siz yeniden dene;
            # diğer hatalar (kota/ağ) çağırana aynen gitsin.
            if "thinking" not in str(exc).lower():
                raise
            response = self._client.models.generate_content(
                model=self.model, contents=prompt, config=self._config(system, False)
            )
        return (response.text or "").strip()

    def __call__(self, prompt: str, **kwargs) -> str:
        return self.invoke(prompt, **kwargs)

"""pytest kurulumu: import yolu + hermetik veri izolasyonu."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import pytest  # noqa: E402

from gastro_agents import config  # noqa: E402
from gastro_agents.tools import density_tool, venue_retriever_tool  # noqa: E402


@pytest.fixture(autouse=True)
def hermetic_datasets(monkeypatch, tmp_path):
    """Testler varsayılan olarak MOCK veriyle koşar.

    data_pipeline'daki gerçek dataset'ler repoda var/yok olabilir; testlerin buna
    bağlı kalmaması için varsayılan olarak yolları boşa alıyoruz. Gerçek veriyi
    sınayan testler (test_real_dataset.py) bu yolları kendisi geri set eder.
    """
    monkeypatch.setattr(config, "PLACES_CSV", tmp_path / "__no_places__.csv")
    monkeypatch.setattr(config, "DENSITY_CSV", tmp_path / "__no_density__.csv")
    venue_retriever_tool.reset_cache()
    density_tool.reset_cache()
    yield
    venue_retriever_tool.reset_cache()
    density_tool.reset_cache()

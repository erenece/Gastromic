# Gastromic — Kurulum ve Çalıştırma

Bu rehber, repoyu klonlayan ekip üyelerinin veya jüri/değerlendiricilerin uygulamayı **yerelde test etmesi** içindir.

## Hızlı başlangıç

```bash
git clone https://github.com/erenece/Gastromic.git
cd Gastromic
```

### 1. Backend (FastAPI)

```bash
pip install -r backend/requirements.txt
pip install -r ai_pipeline/requirements.txt
cp backend/.env.example backend/.env
# backend/.env → GEMINI_API_KEY, GOOGLE_PLACES_API_KEY, service account yolu
# backend/secrets/ → Firebase service account JSON (takımdan isteyin)

uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000
```

Firestore seed (mekan verisi yoksa ekranlar boş kalır):

```bash
python backend/firestore_seed.py --env dev --dry-run
python backend/firestore_seed.py --env dev
```

Detay: [`backend/README.md`](backend/README.md)

### 2. Mobil uygulama (Flutter)

```bash
cd mobile
flutter pub get
cp android/local.properties.example android/local.properties
# GOOGLE_MAPS_API_KEY ekle
# firebase_options_dev.dart, google-services.json → takımdan veya flutterfire configure
```

**Dev (yerel backend):**

```bash
flutter run --flavor dev -t lib/flavors/main_dev.dart
```

**Prod (Render API):**

```bash
flutter run --flavor prod -t lib/flavors/main_prod.dart
```

Detay: [`mobile/README.md`](mobile/README.md)

---

## Gerekli dosyalar (repoda yok — takımdan isteyin)

| Dosya | Konum |
|-------|--------|
| Firebase service account JSON | `backend/secrets/` |
| `google-services.json` | `mobile/android/app/` |
| `firebase_options_dev.dart` | `mobile/lib/` |
| `backend/.env` | API key'ler |

---

## Test senaryosu (önerilen akış)

1. Uygulamayı aç → onboarding → kayıt/giriş
2. Tercihleri doldur (alerji, bütçe, günlük mod)
3. Ana sayfada yakındaki mekanları gör
4. Arama veya detay → AI özet kutusunu kontrol et (**backend açık olmalı**)
5. Bul haritasında filtre dene
6. Yol tarifi → ana sayfada "Şu an buradasınız" kartı → puanlama

---

## Diğer dokümanlar

| Rehber | İçerik |
|--------|--------|
| [`mobile/README.md`](mobile/README.md) | Flutter kurulum, flavor, sorun giderme |
| [`backend/README.md`](backend/README.md) | API, Firestore seed, Chroma indeks |
| [`ai_pipeline/README.md`](ai_pipeline/README.md) | AI ajan katmanı, Gemini, test |
| [`firebase/README.md`](firebase/README.md) | Firestore rules deploy |

---

## Sık sorunlar

| Sorun | Çözüm |
|-------|--------|
| Mekan listesi boş | `firestore_seed.py --env dev` çalıştır |
| AI özet yok | Backend `8000` portunda mı? `GEMINI_API_KEY` var mı? |
| Harita gri | `local.properties` → `GOOGLE_MAPS_API_KEY` |
| Build hatası (Firebase) | `firebase_options_dev.dart` eksik |

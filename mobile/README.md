# Gastromic Mobile

Flutter tabanlı Gastromic mobil uygulaması. Firestore'dan mekan verisi okur; AI özet ve açılış saatleri için backend API kullanır.

## Gereksinimler

- Flutter SDK **3.38+** (Dart **3.11+**)
- Android Studio veya VS Code + Android SDK
- Firebase projesi erişimi (`gastromic-dev` geliştirme için)
- Google Maps API key (Android Maps SDK etkin)

## Hızlı kurulum

```bash
cd mobile
flutter pub get
```

### 1. Firebase dosyaları

Bu dosyalar repoda **yoktur** (gitignore). Takım yöneticisinden isteyin veya FlutterFire CLI ile üretin:

```bash
# Repo kökünden (firebase.json repoda mevcut)
dart pub global activate flutterfire_cli
flutterfire configure
```

Oluşması gereken dosyalar:

| Dosya | Açıklama |
|-------|----------|
| `lib/firebase_options_dev.dart` | Dev Firebase yapılandırması |
| `lib/firebase_options_prod.dart` | Prod Firebase yapılandırması |
| `android/app/google-services.json` | Android Firebase config |

### 2. Google Maps API key

```bash
cp android/local.properties.example android/local.properties
```

`android/local.properties` içine ekleyin:

```properties
sdk.dir=C:\\Users\\YOUR_USER\\AppData\\Local\\Android\\sdk
flutter.sdk=C:\\src\\flutter
GOOGLE_MAPS_API_KEY=YOUR_KEY_HERE
```

Google Cloud Console'da **Maps SDK for Android** etkin olmalı.

### 3. Backend (opsiyonel ama önerilir)

AI özet, açılış saatleri ve bazı öneriler backend gerektirir. Bkz. [`../backend/README.md`](../backend/README.md).

Dev flavor varsayılan API adresi: `http://10.0.2.2:8000` (Android emülatör → host makine).

```bash
# Repo kökünden
uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000
```

Firestore'da mekan verisi yoksa ekranlar boş görünür. Seed:

```bash
python backend/firestore_seed.py --env dev --dry-run
python backend/firestore_seed.py --env dev
```

## Çalıştırma

### Dev (yerel backend)

```bash
flutter run --flavor dev -t lib/flavors/main_dev.dart
```

### Prod (Render API)

```bash
flutter run --flavor prod -t lib/flavors/main_prod.dart
```

Fiziksel cihazda dev backend kullanıyorsanız `lib/flavors/main_dev.dart` içindeki `apiUrl` değerini bilgisayarınızın LAN IP'si ile değiştirin (`http://192.168.x.x:8000`).

## Flavor özeti

| Flavor | Entry point | Application ID | Backend |
|--------|-------------|----------------|---------|
| `dev` | `lib/flavors/main_dev.dart` | `com.example.gastromic.dev` | `http://10.0.2.2:8000` |
| `prod` | `lib/flavors/main_prod.dart` | `com.example.gastromic` | `https://gastromic-api.onrender.com` |

## Sık karşılaşılan sorunlar

**`firebase_options_dev.dart` bulunamadı**  
→ FlutterFire configure çalıştırın veya takımdan dosyayı alın.

**Harita boş / gri kutu**  
→ `GOOGLE_MAPS_API_KEY` eksik veya Maps SDK etkin değil.

**Mekan listesi boş**  
→ Firestore `venues` koleksiyonu seed edilmemiş veya Firebase projesi yanlış.

**AI özet gelmiyor**  
→ Backend çalışmıyor veya `GEMINI_API_KEY` tanımlı değil (backend mock moda düşer).

## Proje yapısı

```
lib/
  app/views/          # Ekranlar (home, search, venue detail, …)
  core/               # Servisler, modeller, yardımcılar
  flavors/            # dev / prod entry point'leri
```

## Güvenlik notu

Asla commit etmeyin: `local.properties`, `google-services.json`, `firebase_options_*.dart`, `key.properties`, `.jks` dosyaları.

# Firebase Service Account (gitignore'da)

Bu klasöre Firebase Console'dan indirdiğiniz private key JSON dosyalarını koyun:

- `gastromic-dev.json` → gastromic-dev projesi
- `gastromic-prod.json` → gastromic-prod projesi

**İndirme:** [Firebase Console](https://console.firebase.google.com) → Project Settings → Service Accounts → **Generate new private key**

Sonra:

```bash
python backend/firestore_seed.py --env dev
python backend/firestore_seed.py --env prod
```

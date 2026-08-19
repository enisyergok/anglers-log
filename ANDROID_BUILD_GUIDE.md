# Angler's Log - Android Build Rehberi

Bu doküman, Angler's Log Flutter projesini GitHub Actions kullanarak Android APK olarak derleme sürecini açıklar.

## 📋 Gereksinimler

Projenin GitHub Actions ile otomatik derlenebilmesi için aşağıdaki adımları izleyin:

### 1. Depoyu Hazırlama

- Projenizin `main` branch'inde olduğundan emin olun.
- `mobile/assets/sensitive.properties` dosyası GitHub Actions tarafından otomatik oluşturulur (dummy değerlerle).

### 2. GitHub Secrets Ayarlama (Opsiyonel - İmzalı APK için)

Eğer uygulamanızı Google Play Store'da yayınladıysanız veya imzalı APK istiyorsanız, aşağıdaki secrets'ları GitHub repo ayarlarından eklemelisiniz:

**Ayarlar > Secrets and variables > Actions** bölümüne gidin ve **"New repository secret"** butonuna tıklayarak aşağıdakileri ekleyin:

| Secret Name | Açıklama | Örnek Değer |
|-------------|----------|-------------|
| `ANDROID_KEYSTORE_BASE64` | Keystore dosyanızın base64 kodlanmış hali | `base64 anglers-log-release.keystore` komutuyla elde edilir |
| `ANDROID_STORE_PASSWORD` | Keystore şifresi | `yourStorePassword` |
| `ANDROID_KEY_ALIAS` | Anahtar alias adı | `yourKeyAlias` |
| `ANDROID_KEY_PASSWORD` | Anahtar şifresi | `yourKeyPassword` |

**Keystore'u base64'e çevirme (Linux/Mac):**
```bash
base64 -w 0 anglers-log-release.keystore
```

**Windows PowerShell:**
```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("anglers-log-release.keystore"))
```

### 3. Derleme İşlemleri

#### Otomatik Derleme
- **Push:** `main` branch'ine her push yapıldığında otomatik derlenir.
- **Tag:** `v*` formatında tag (örn: `v1.0.0`) oluşturulduğunda otomatik derlenir ve GitHub Release oluşturulur.

#### Manuel Derleme
- **Actions** sekmesine gidin.
- Sol menüden **"Build Android APK"** workflow'unu seçin.
- **"Run workflow"** butonuna tıklayın.
- Branch seçin (varsayılan: `main`).
- **"Run workflow"** butonuna tekrar tıklayın.

### 4. APK'yı İndirme

Derleme tamamlandığında:

1. Workflow sayfasında **"artifacts"** bölümünü bulun.
2. `anglers-log-apk-{commit-hash}` linkine tıklayın.
3. ZIP dosyasını indirin ve açın.
4. `app-release.apk` dosyası Android cihazınıza kurulabilir.

### 5. Sürüm Oluşturma (Release)

Eğer bir tag (`v1.0.0` gibi) ile push yaparsanız:
- APK otomatik olarak derlenir.
- GitHub Releases sayfasında yeni bir release oluşturulur.
- APK dosyası release'e eklenir.
- Release notları otomatik olarak oluşturulur.

## 🔧 Troubleshooting

### Derleme Başarısız Olursa

1. **Actions loglarını kontrol edin:** Hata mesajını okuyun.
2. **Flutter versyonu:** Workflow en son stabil Flutter versiyonunu kullanır.
3. **Bağımlılıklar:** `mobile/pubspec.yaml` dosyasındaki bağımlılıkların doğru olduğundan emin olun.
4. **adair-flutter-lib:** Bu kütüphane otomatik olarak clone edilir, internet bağlantınızı kontrol edin.

### İmzalama Hatası

- Secrets'ların doğru girildiğinden emin olun.
- Keystore dosyasının geçerli olduğunu kontrol edin.
- Şifrelerin doğru olduğundan emin olun.

## 📱 APK'yı Cihaza Yükleme

1. APK dosyasını telefonunuza aktarın (USB, email, cloud storage vb.).
2. Telefonunuzda **"Bilinmeyen Kaynaklar"** seçeneğini aktif edin.
3. APK dosyasına tıklayarak yükleyin.

## 🚀 Sonraki Adımlar

- Uygulamayı Google Play Console'a yüklemek için `.aab` (Android App Bundle) formatında derleyin.
- Beta testleri için Firebase App Distribution kullanın.
- CI/CD pipeline'ına test adımları ekleyin.

---

**Not:** Bu proje tamamen offline çalışacak şekilde tasarlanmıştır. Veriler cihazda SQLite veritabanında saklanır, internet bağlantısı gerektirmez.

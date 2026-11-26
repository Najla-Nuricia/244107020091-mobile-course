# Laporan Rilis Beta — week5_offline_notes

Disusun 26 November 2026. Kandidat `beta-1`, versi **1.1.0+4**, commit **`f1aa2f5`**, tag **`v1.1.0-beta1`**.

## 1. Identitas kandidat

| Field | Nilai |
| --- | --- |
| Versi / build | 1.1.0 / 4 (`versionName=1.1.0`, `versionCode=4`) |
| Commit | `f1aa2f5a5e2cc05eff7daa0da7c7174aee6afb55` |
| Tag | `v1.1.0-beta1` |
| Kondisi Git | clean saat build; artefak dapat dipetakan ke satu commit |
| Package | `com.example.week5_offline_notes` |
| Firebase | `campus-notify-5a928`, app `1:1022630052540:android:b50669d7beb9d091c306b9` |
| AAB | 59.889.468 bytes, SHA-256 `02d19fd0…c62caf` |
| APK terdistribusi | 60.083.676 bytes, SHA-256 `36a704b5…d94d7ba` |
| Signing | keystore rilis di luar repo; sertifikat SHA-256 `87d4f8e3…5325bb` |
| Flag build | `--dart-define=ENABLE_BETA_PROBE=true` |

Detail lengkap: [`beta-candidate-metadata.txt`](./beta-candidate-metadata.txt).

## 2. Bukti distribusi

Distribusi **benar-benar dilakukan** ke Firebase App Distribution, bukan direncanakan saja.

| Bukti | Nilai |
| --- | --- |
| Perintah | `firebase appdistribution:distribute ... --groups beta-testers` |
| Hasil | `uploaded new release 1.1.0 (4) successfully!`, `distributed to testers/groups successfully` |
| Release ID | `0u0b3pgpdqn58` |
| Waktu dibuat | 2026-11-26T10:22:58Z |
| Grup | `beta-testers` — 1 tester (email tidak dicantumkan di laporan) |
| Tautan konsol | https://console.firebase.google.com/project/campus-notify-5a928/appdistribution/app/android:com.example.week5_offline_notes/releases/0u0b3pgpdqn58 |
| Verifikasi API | `releases.list` HTTP 200, `groups.list` HTTP 200 (`testerCount: 1`, `releaseCount: 1`) |

Log unggahan (tautan unduh dengan token pendek sudah dihapus): [`app-distribution-upload.log`](./app-distribution-upload.log).
Hasil pembacaan dashboard: [`dashboard-verification.txt`](./dashboard-verification.txt).

**Keterbatasan distribusi:** unggahan AAB ditolak dengan pesan bahwa project Firebase belum terhubung ke akun Google Play Console, dan akun Play Console tidak tersedia di lingkungan ini. Karena itu yang didistribusikan adalah **APK rilis dari commit, signing, dan flag build yang sama** dengan AAB. AAB tetap dibangun, diverifikasi, dan dicatat checksum-nya. Lihat [`aab-upload-attempt.log`](./aab-upload-attempt.log).

## 3. Hasil uji

| Pemeriksaan | Perintah | Hasil |
| --- | --- | --- |
| Dependensi | `flutter pub get` | PASS |
| Format | `dart format --output=none --set-exit-if-changed .` | PASS — 36 file, 0 berubah |
| Analisis | `flutter analyze --fatal-infos` | PASS — `No issues found!` |
| Test | `flutter test --reporter expanded` | PASS — 27/27 |
| AAB | `flutter build appbundle --release --dart-define=ENABLE_BETA_PROBE=true` | PASS — 59,9 MB |
| APK | `flutter build apk --release --dart-define=ENABLE_BETA_PROBE=true` | PASS — 60,1 MB |
| Tanda tangan | `apksigner verify --print-certs app-release.apk` | PASS — V2, sertifikat `CN=Offline Notes Beta` |
| Instalasi | `adb install` dari biner hasil unduhan App Distribution | PASS — `versionName 1.1.0`, `versionCode 4` |

Log: [`beta-candidate-checks.log`](./beta-candidate-checks.log), [`beta-aab-build.log`](./beta-aab-build.log).

### Uji perangkat

Perangkat: Infinix X6882, Android 14 (SDK 34), `arm64-v8a`, serial disamarkan.

1. Aplikasi dibuka dari launcher; beranda menampilkan daftar catatan dan status sinkronisasi.
2. Tombol **Kirim masukan** ditekan → snackbar `Masukan beta tercatat.` Muncul satu event Analytics `beta_feedback_sent` dengan parameter tetap `screen_name=home`. Tidak ada isi formulir, email, atau ID pengguna yang dikirim.
3. Tombol **Uji monitoring beta** (hanya ada pada build dengan `ENABLE_BETA_PROBE=true`) ditekan → snackbar `Probe Crashlytics terkirim.`
4. Logcat menunjukkan Crashlytics aktif, sesi dibuka, dan laporan non-fatal berhasil dienque ke DataTransport lalu terkirim (`crashlyticsreports-pa.googleapis.com`).
5. Tidak ada crash fatal yang dipicu.

Bukti: [`screenshots/device-home.png`](./screenshots/device-home.png), [`screenshots/device-feedback.png`](./screenshots/device-feedback.png), [`screenshots/device-telemetry.png`](./screenshots/device-telemetry.png), [`device-test-log.txt`](./device-test-log.txt).

### Verifikasi telemetry di dashboard

Crashlytics **terverifikasi di dashboard** melalui Crashlytics API:

- Issue `ca417bae60a4992ebabfd1cfc530011f`
- Judul: `package:week5_offline_notes/monitoring.dart - .recordNonFatalProbe`
- Subtitle: `Bad state: beta_device_check. Error thrown monitoring_probe.`
- `errorType: NON_FATAL`, `firstSeenVersion`/`lastSeenVersion`: `1.1.0`, state `OPEN`
- Metrik 7 hari: 1 event, 1 pengguna terdampak, 2 sesi total
- Tautan issue: https://console.firebase.google.com/v1/appid/project/campus-notify-5a928/crashlytics/app/1:1022630052540:android:b50669d7beb9d091c306b9/issues/ca417bae60a4992ebabfd1cfc530011f

Analytics: event berhasil dipicu dan dicatat di perangkat (log mode debug Firebase Analytics menunjukkan aktivitas `logEvent`, dan UI mengonfirmasi aksi tester). **Pembacaan balik di dashboard GA4 tidak dapat dilakukan** dengan kredensial yang tersedia: OAuth CLI hanya memiliki scope `cloud-platform`, `firebase`, dan `userinfo.email`, sedangkan Analytics Data/Admin API memerlukan scope `analytics` serta izin level properti GA4. Tidak ada klaim angka event GA4 di laporan ini. Verifikasi manual dapat dilakukan di Firebase console → Analytics → DebugView dengan perangkat yang sama; petunjuk ada di bagian langkah berikutnya.

## 4. Temuan

1. Perbaikan sebelum build akhir: `lib/app/app.dart` perlu diformat ulang setelah penambahan tombol probe; setelah `dart format .` dijalankan, seluruh pemeriksaan dijalankan ulang dan lulus.
2. AAB tidak dapat diunggah ke App Distribution tanpa keterkaitan Firebase–Play Console. Solusi yang dipakai: APK dari commit yang sama. Ini adalah keterbatasan nyata, bukan bukti yang dibuat-buat.
3. Aplikasi yang lama terpasang di perangkat bertanda tangan debug, sehingga `adb install -r` gagal dengan `INSTALL_FAILED_UPDATE_INCOMPATIBLE`. Aplikasi lama di-uninstall lalu biner beta dipasang bersih. Signing rilis kini memakai keystore di luar repository; `android/key.properties` masuk `.gitignore`.
4. Tombol probe hanya dikompilasi lewat `--dart-define=ENABLE_BETA_PROBE=true`. Build produksi tanpa flag tidak menyediakan pemicu error buatan.
5. Satu issue non-fatal muncul di Crashlytics sesuai probe yang sengaja dipicu. Angka `crashFreeSessionsPercentage: 50` berasal dari sampel sangat kecil (2 sesi, 1 probe) dan tidak boleh diartikan sebagai kualitas rilis.
6. Verifikasi GA4 terkendala scope OAuth; ini dicatat sebagai keterbatasan, bukan sebagai keberhasilan verifikasi.

## 5. Dampak

- **Fungsional:** perubahan terbatas pada startup (inisialisasi Firebase + penangan error),tombol Kirim masukan, tombol probe beta, dan konfigurasi signing Android. Seluruh 27 test masih lulus dan alur utama notes berjalan di perangkat.
- **Operasional:** build beta kini benar-benar tersedia untuk tester internal melalui tautan App Distribution. Satu tester terdaftar dan satu release aktif.
- **Data:** satu event non-sensitif dan satu error non-fatal buatan masuk ke layanan monitoring. Tidak ada catatan, email, token, atau identifier pribadi yang dikirim.
- **Risiko:** sampel uji masih satu perangkat dan satu tester, sehingga metrik agregat belum representatif. Rilis publik tetap memerlukan AAB dari Play Console dan verifikasi GA4 yang benar.

## 6. Keputusan

**Lanjut untuk beta internal terbatas; tahan perluasan ke produksi.**

Alasan: kandidat memiliki commit/tag yang dapat direproduksi, seluruh pemeriksaan lulus, artefak benar-benar terdistribusi dan terpasang di perangkat nyata, serta crash non-fatal yang dipicu terlihat di dashboard Crashlytics. Penahanan produksi dilakukan karena distribusi memakai APK (bukan AAB), sampel tester masih sangat kecil, dan angka Analytics belum diverifikasi di dashboard. Penanggung jawab: Najla Nuricia Laudy (TI-3F).

## 7. Langkah berikutnya

1. Hubungkan project Firebase ke akun Google Play Console, lalu unggah AAB bertag `v1.1.0-beta1` ke **Internal testing** dan undang tester melalui konsol.
2. Perbesar jumlah tester internal dan kumpulkan laporan terstruktur (versi, perangkat, OS, langkah reproduksi, hasil harapan vs aktual, bukti disamarkan).
3. Verifikasi event `beta_feedback_sent` di Firebase console → Analytics → DebugView/Dashboard dengan `adb shell setprop debug.firebase.analytics.app com.example.week5_offline_notes`, atau berikan akses properti GA4 pada akun verifikasi untuk pembacaan API.
4. Pantau crash-free users/sessions, issue baru, pengguna terdampak, dan versi sebelum memutuskan perluasan rilis.
5. Simpan keystore rilis di secrets pipeline CI dan pastikan build produksi tidak memakai signing debug.
6. Jika muncul issue pada alur utama, reproduksi, perbaiki, naikkan build number, dan ulangi distribusi; hentikan/rollback track bila dampaknya luas.

## 8. Penggunaan AI dan log yang disamarkan

Asisten AI dipakai untuk merangkai laporan, mengecek urutan perintah codelab, menafsirkan hasil pemeriksaan, dan membantu menyiapkan kueri REST API untuk verifikasi dashboard. Konteks yang diberikan hanya berupa ringkasan buatan sendiri: path file lokal, nomor versi/build, hash artefak, status perintah (`No issues found`, `All tests passed`), serta cuplikan respons API yang sudah dihapus email/token/ID perangkatnya.

```text
versi = 1.1.0+4
commit = f1aa2f5
hasil analisis = No issues found
hasil test = 27/27 passed
sha256 AAB = 02d19fd0...c62caf
status rilis = uploaded, release id 0u0b3pgpdqn58
```

Saran AI diverifikasi dengan cara berikut:

- Setiap perintah dijalankan kembali di lingkungan ini dan keluarannya dibaca langsung, bukan dipercaya dari ringkasan.
- Klaim analisis/test lolos dicek dari log [`beta-candidate-checks.log`](./beta-candidate-checks.log).
- Klaim distribusi dicek dari log unggahan dan pembacaan `releases.list`/`groups.list` melalui API.
- Klaim Crashlytics terverifikasi dicek dari `topIssues` dan `issue.get` yang mengembalikan judul, subtitle, versi, dan metrik.
- Klaim Analytics sengaja **tidak** dibuat berdasarkan dugaan AI; bukti yang ada hanya berasal dari perangkat dan log SDK.

## 9. Batasan

- Tidak ada bukti dashboard GA4 karena keterbatasan scope kredensial; tidak ada angka event GA4 yang diklaim.
- Tidak ada bukti Google Play Internal testing karena akun Play Console tidak tersedia karena berbayar.
- Email tester, serial perangkat lengkap, token unduh, token OAuth, password keystore, dan kunci privat tidak disimpan di repository maupun di dokumen ini.
- Semua angka yang tercantum berasal dari perintah lokal atau pembacaan API yang dapat diulang dengan kredensial yang sesuai.

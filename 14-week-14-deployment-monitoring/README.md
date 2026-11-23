# Minggu 14 — Deployment dan Monitoring

**Nama:** Najla Nuricia Laudy
**Kelas:** TI-3F
**NIM:** 244107020091

Project yang dipakai adalah [`week5_offline_notes`](./week5_offline_notes/), salinan dari project minggu 13 yang sudah lolos CI. Perubahan minggu ini menambahkan kandidat beta dan telemetry. Seluruh perubahan masih berupa worktree yang belum di-commit sesuai instruksi.

## Kandidat beta

| Item | Nilai |
| --- | --- |
| Nama kandidat | beta-1 |
| Versi aplikasi | 1.1.0 |
| Build number | 3 |
| Commit dasar | `6880d11` |
| Package Android | `com.example.week5_offline_notes` |
| Firebase project | `campus-notify-5a928` |
| Firebase Android app id | `1:1022630052540:android:b50669d7beb9d091c306b9` |
| AAB | `build/app/outputs/bundle/release/app-release.aab` |
| Ukuran AAB | 59888061 bytes |
| SHA-256 AAB | `82d459f019424e1ca6c6775bd86eeb035fc228647685824af1a9bd5a9fdbede0` |

Commit dasar adalah HEAD repository saat pengerjaan. Karena perubahan tidak di-commit, AAB ini tidak dapat dipetakan ke satu commit unik. Sebelum distribusi nyata, buat commit atau tag dari worktree ini lalu bangun ulang AAB.

## Perubahan kode

- [`lib/monitoring.dart`](./week5_offline_notes/lib/monitoring.dart) menginisialisasi Firebase, memasang `FlutterError.onError` dan `PlatformDispatcher.instance.onError` ke Crashlytics, menyediakan probe non-fatal, dan mengirim event Analytics.
- [`lib/app/app.dart`](./week5_offline_notes/lib/app/app.dart) memanggil `initMonitoring()` setelah binding dan database siap. Tombol Kirim masukan di beranda memanggil `logBetaFeedback`.
- [`lib/firebase_options.dart`](./week5_offline_notes/lib/firebase_options.dart) dan [`android/app/google-services.json`](./week5_offline_notes/android/app/google-services.json) dihasilkan oleh `flutterfire configure` untuk project `campus-notify-5a928`.
- `android/app/build.gradle.kts` dan `android/settings.gradle.kts` memuat plugin Google Services dan Crashlytics.
- `pubspec.yaml` menaikkan versi menjadi `1.1.0+3` dan menambah `firebase_core`, `firebase_crashlytics`, serta `firebase_analytics`.

## Pemeriksaan kandidat

| Step | Perintah | Hasil |
| --- | --- | --- |
| Dependensi | `flutter pub get` | PASS |
| Format | `dart format --output=none --set-exit-if-changed .` | PASS, 36 file tidak berubah |
| Analisis | `flutter analyze --fatal-infos` | PASS, No issues found |
| Test | `flutter test` | PASS, 27 test |
| Build | `flutter build appbundle --release` | PASS, 59,9 MB |

Log lengkap ada di [`docs/beta-candidate-checks.log`](./docs/beta-candidate-checks.log), [`docs/beta-aab-build.log`](./docs/beta-aab-build.log), dan [`docs/beta-candidate-metadata.txt`](./docs/beta-candidate-metadata.txt). Saat format pertama dijalankan, `lib/monitoring.dart` perlu diformat. Analisis pertama juga menemui import `dart:ui` yang tidak diperlukan karena `package:flutter/foundation.dart` sudah menyediakan `PlatformDispatcher`. Keduanya diperbaiki lalu seluruh pemeriksaan dijalankan ulang sampai lulus.

## Event yang dicatat

| Nama | Parameter | Arti |
| --- | --- | --- |
| `beta_feedback_sent` | `screen_name` tetap `home` | Tester mengetuk tombol Kirim masukan di beranda. Tidak mengirim isi masukan, email, atau identifier pribadi. |

Probe non-fatal `recordNonFatalProbe` memakai reason tetap `monitoring_probe` dan sengaja tidak dipanggil dari alur produksi. Probe ini hanya dipakai untuk verifikasi manual bila perangkat uji tersedia.

## Keamanan

- `google-services.json` berisi konfigurasi publik Firebase, bukan credential rahasia. Kunci penandatanganan tetap tidak disimpan di repository.
- Build release masih memakai signing debug bawaan. Ini hanya cukup untuk uji internal dan harus diganti sebelum rilis publik.
- Tidak ada token, password, email tester, atau data pribadi yang ditulis ke log atau ke telemetry.
- Nilai yang dikompilasi ke aplikasi tidak dianggap sebagai rahasia.

## Refleksi

- Sebelum memperluas distribusi, diperlukan AAB dari commit yang bersih, signing yang benar, tester terdaftar, bukti instalasi, event dan crash yang terverifikasi di dashboard, serta laporan bug yang sudah direproduksi.
- Keputusan menahan rilis diambil karena tidak ada bukti distribusi dan tidak ada verifikasi telemetry. Ini bukan kegagalan build, melainkan bukti yang belum memadai.
- Data yang tidak perlu dikirim antara lain isi catatan, email, token, ID pengguna, URL privat, dan payload formulir.

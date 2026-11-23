# Laporan Rilis Beta

Kandidat beta-1 untuk `week5_offline_notes`, disusun 23 November 2026.

## 1. Identitas kandidat

| Field | Nilai |
| --- | --- |
| Versi dan build | 1.1.0+3 |
| Commit dasar | `6880d1195ee82abd69ce2698947b0adb1eddb74e` |
| Kondisi Git | worktree belum di-commit sesuai instruksi pengguna |
| Package | `com.example.week5_offline_notes` |
| Firebase project | `campus-notify-5a928` |
| Firebase Android app id | `1:1022630052540:android:b50669d7beb9d091c306b9` |
| AAB | `../week5_offline_notes/build/app/outputs/bundle/release/app-release.aab` |
| Ukuran AAB | 59888061 bytes |
| SHA-256 AAB | `82d459f019424e1ca6c6775bd86eeb035fc228647685824af1a9bd5a9fdbede0` |
| Flutter | 3.47.1 |

Sumber data ada di [`beta-candidate-metadata.txt`](./beta-candidate-metadata.txt).

## 2. Bukti distribusi
Belum ada distribusi nyata yang dilakukan pada kandidat ini. Tidak ada unggahan ke Google Play Internal testing dan tidak ada unggahan ke Firebase App Distribution.

Alasan:

- Akun Google Play Console tidak tersedia di lingkungan ini.
- Firebase App Distribution memerlukan daftar email tester yang tidak diberikan.
- Tidak ada perangkat Android fisik. Satu emulator tersedia tetapi `PlayStore.enabled` bernilai `no`, sehingga layanan Google Play yang dibutuhkan Analytics dan Crashlytics tidak dapat diandalkan.
- Membuat tangkapan dashboard atau daftar tester palsu dilarang oleh codelab, jadi tidak ada bukti tersebut di repository.

Bukti yang benar-benar ada hanyalah artefak lokal berupa AAB beserta checksum, konfigurasi Firebase yang dihasilkan oleh `flutterfire configure`, dan log pemeriksaan. Artefak AAB tidak dibagikan ke publik.

## 3. Hasil uji

| Pemeriksaan | Perintah | Hasil |
| --- | --- | --- |
| Dependensi | `flutter pub get` | PASS |
| Format | `dart format --output=none --set-exit-if-changed .` | PASS, 36 file, 0 berubah |
| Analisis statis | `flutter analyze --fatal-infos` | PASS, No issues found |
| Unit dan widget test | `flutter test` | PASS, 27 dari 27 |
| Build AAB | `flutter build appbundle --release` | PASS, 59,9 MB |

Log mentah ada di [`beta-candidate-checks.log`](./beta-candidate-checks.log) dan [`beta-aab-build.log`](./beta-aab-build.log).

Telemetry belum diverifikasi di dashboard. Kode sudah memuat inisialisasi Firebase, penangan error fatal, dan event `beta_feedback_sent` dengan parameter `screen_name` bernilai `home`. Tidak ada error uji non-fatal maupun crash fatal yang dikirim dari perangkat, jadi angka crash-free users dan daftar issue belum tersedia.

## 4. Temuan

- Dua masalah ditemukan saat pemeriksaan awal dan sudah diperbaiki sebelum build akhir. Pertama, file `lib/monitoring.dart` belum terformat sehingga `dart format` dengan `--set-exit-if-changed` gagal. Kedua, `flutter analyze --fatal-infos` menandai import `dart:ui` sebagai tidak perlu karena `package:flutter/foundation.dart` sudah mengekspor `PlatformDispatcher`.
- `flutterfire configure` berhasil mendaftarkan package `com.example.week5_offline_notes` ke project Firebase `campus-notify-5a928` yang sudah dipakai project minggu 6 dan menghasilkan `google-services.json` beserta `firebase_options.dart`. Pendaftaran ini adalah perubahan nyata pada project Firebase eksternal dan perlu diketahui pemilik project.
- Build release masih menggunakan signing debug bawaan dari project minggu 13. Ini bukan konfigurasi yang layak untuk rilis publik.
- Karena perubahan tidak di-commit, identitas kandidat belum bisa direproduksi dari satu SHA Git. AAB harus dibangun ulang setelah commit atau tag dibuat.

## 5. Dampak

- Dampak teknis dari perubahan kode kecil dan terbatas pada startup aplikasi, tombol Kirim masukan di beranda, serta konfigurasi build Android. Seluruh test yang ada masih lulus.
- Dampak operasional belum teramati karena tidak ada tester yang memakai build ini.
- Risiko utama adalah keputusan rilis diambil tanpa data distribusi dan telemetry. Data agregat belum ada, sehingga tidak ada dasar untuk menyatakan build bebas crash di perangkat nyata.
- Risiko sekunder adalah penggunaan signing debug. Jika AAB ini sampai terdistribusi, aplikasi akan bertanda tangan dengan kunci yang tidak terkontrol dengan baik.

## 6. Keputusan

Rilis ditahan. Alasannya bukan kegagalan pemeriksaan otomatis, melainkan ketiadaan bukti distribusi, ketiadaan perangkat uji yang mendukung telemetry, dan konfigurasi signing yang belum sesuai untuk rilis.

Keputusan ini bersifat sementara. Rilis dapat dilanjutkan setelah kriteria di bagian berikutnya terpenuhi. Penanggung jawab untuk langkah berikutnya adalah pemilik project, yaitu Najla Nuricia Laudy. Perbaikan yang dibutuhkan adalah membuat commit bersih, menyiapkan signing rilis, dan mengulang distribusi serta verifikasi telemetry.

## 7. Langkah berikutnya

1. Commit seluruh worktree minggu 14 lalu buat tag `v1.1.0-beta1` dari commit tersebut.
2. Bangun ulang AAB dari commit bertag dan rekam SHA-256 terbaru.
3. Siapkan signing rilis dengan keystore yang disimpan di luar repository dan disuntikkan lewat secrets pada pipeline.
4. Daftar tester internal dengan email yang benar-benar diberikan, lalu unggah AAB ke Internal testing atau Firebase App Distribution.
5. Instal di perangkat Android nyata dan jalankan alur utama, termasuk mengetuk tombol Kirim masukan.
6. Picu satu error non-fatal buatan lewat `recordNonFatalProbe` hanya pada perangkat uji, lalu tunggu pemrosesan dan periksa event, versi aplikasi, perangkat, serta stack trace di dashboard.
7. Uji crash fatal hanya sesuai instruksi resmi Firebase dan hanya pada perangkat uji.
8. Catat crash-free users, issue baru, jumlah pengguna terdampak, versi, dan laporan tester sebelum memutuskan perluasan distribusi.
9. Jika masalah muncul pada alur utama, tahan distribusi dan ikuti prosedur penghentian atau rollback track.

## 8. Penggunaan AI dan log yang disamarkan

Asisten AI dipakai untuk merangkai dokumentasi, mengecek urutan perintah codelab, dan menafsirkan hasil pemeriksaan lokal. Konteks yang diberikan berupa ringkasan buatan sendiri, bukan log mentah dari layanan eksternal. Ringkasan itu hanya berisi path file lokal, nomor versi, sha256 artefak, serta baris hasil perintah seperti `No issues found` dan `All tests passed`. Tidak ada email, token, kredensial, ID pengguna, URL privat, atau isi catatan yang disalin ke percakapan.

Contoh konteks yang disamarkan.

```text
versi = 1.1.0+3
commit dasar = 6880d11
hasil analisis = No issues found
hasil test = All tests passed
sha256 artefak = 82d459f0...fdbede0
```

Saran AI diverifikasi dengan cara berikut.

- Setiap perintah yang disarankan dijalankan kembali di project dan keluarannya dibaca langsung, bukan dipercaya begitu saja.
- Saran penanganan error fatal dan non-fatal dibandingkan dengan dokumentasi resmi FlutterFire dan kode paket yang terpasang.
- Klaim bahwa analisis lolos dicek dengan menjalankan `flutter analyze --fatal-infos`, bukan hanya dengan membaca ringkasan.
- Klaim bahwa test lolos dicek dari log `flutter test` yang menunjukkan 27 test selesai.
- Tidak ada saran AI yang dipakai sebagai pengganti bukti distribusi atau bukti dashboard.

## 9. Batasan

Laporan ini belum berisi bukti dashboard, tangkapan layar konsol, daftar tester, atau catatan instalasi perangkat karena hal tersebut tidak benar-benar dilakukan. Semua angka yang tercantum berasal dari perintah lokal yang dapat diulang. Status telemetry adalah terkonfigurasi pada level kode dan konfigurasi, bukan terverifikasi pada level layanan.

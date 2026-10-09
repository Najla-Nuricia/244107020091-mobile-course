# Audit Usulan Clean Architecture — `campus_notify`

## 1. Struktur Layer

| File                        | Layer        | Catatan                                                |
| --------------------------- | ------------ | ------------------------------------------------------ |
| `main.dart`                 | Presentation | Halaman dipisah ke file masing-masing agar lebih rapi. |
| `auth_providers.dart`       | Presentation | Mengatur state login dan koneksi ke repository.        |
| `auth_repository.dart`      | Domain       | Berisi aturan dan kontrak autentikasi.                 |
| `auth_repository_impl.dart` | Data         | Menjalankan proses autentikasi.                        |
| `token_store.dart`          | Data         | Menyimpan token secara aman.                           |
| `api_client.dart`           | Core         | Mengatur komunikasi dengan API.                        |
| `push_service.dart`         | Data         | Mengatur notifikasi Firebase.                          |
| `routes.dart`               | Routing      | Mengatur perpindahan halaman.                          |

## 2. Tiga Pemeriksaan

| Pemeriksaan                                 | Hasil                                                             |
| ------------------------------------------- | ----------------------------------------------------------------- |
| Akses API atau storage langsung di halaman  | Tidak ditemukan.                                                  |
| Format tanggal atau parsing JSON di halaman | Tidak ditemukan.                                                  |
| Pembuatan repository atau Dio di halaman    | Tidak ditemukan. Pembuatan dependency dilakukan melalui provider. |

## 3. Rencana Perbaikan

* Memisahkan halaman sesuai fiturnya.
* Memisahkan kontrak repository dan implementasinya.
* Memindahkan akses Firebase dari halaman ke service.
* Mengatur dependency menggunakan Riverpod.
* Tidak menambahkan use case atau model pengumuman sebelum dibutuhkan.

## Kesimpulan

Struktur proyek sudah cukup rapi dan pembagian layer sudah lebih jelas. Beberapa bagian masih bisa diperbaiki agar kode lebih mudah dibaca, diuji, dan dikembangkan.

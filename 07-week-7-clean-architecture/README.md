# Week 7 — Clean Architecture

Nama: Najla Nuricia Laudy
Kelas: TI-3F
NIM: 244107020091

Audit ini menggunakan proyek Minggu 6, yaitu `06-week-6-authentication-security-fcm/campus_notify`.

## Pemetaan Layer Saat Ini

| File                               | Layer                     | Masalah / Catatan                                                                                               |
| ---------------------------------- | ------------------------- | --------------------------------------------------------------------------------------------------------------- |
| `lib/main.dart`                    | Presentation + routing    | Beberapa halaman masih digabung dalam satu file. Akses Firebase di `HomePage` sebaiknya dipindahkan ke service. |
| `lib/providers/auth_provider.dart` | Presentation              | Provider masih bergantung pada error Dio. Sebaiknya error diolah agar tidak bergantung langsung pada Dio.       |
| `lib/data/auth_repository.dart`    | Data                      | `AuthSession` dan `AuthRepository` masih satu file. Repository juga masih berupa simulasi.                      |
| `lib/data/api_client.dart`         | Data                      | Pengaturan Dio sudah berada di tempat yang sesuai.                                                              |
| `lib/data/token_store.dart`        | Data                      | Kontrak `SessionStore` masih digabung dengan implementasinya. Sebaiknya dipisahkan.                             |
| `lib/messaging/push_service.dart`  | Data / integrasi Firebase | Mengurus notifikasi dan token perangkat. Sebaiknya dipisahkan dari halaman.                                     |
| `lib/routes.dart`                  | Routing                   | Pengaturan rute bisa dipisahkan agar struktur kode lebih rapi.                                                  |

## Tiga Pelanggaran Klasik

Folder `lib/pages` dan `lib/widgets` belum tersedia, jadi pemeriksaan dilakukan pada folder `lib/`.

| Pemeriksaan                                      | Hasil                     | Catatan                                                                                  |
| ------------------------------------------------ | ------------------------- | ---------------------------------------------------------------------------------------- |
| Akses jaringan, database, atau storage di widget | Tidak ditemukan           | Namun, `HomePage` masih mengakses Firebase Messaging secara langsung.                    |
| Format tanggal atau parsing JSON di widget       | Tidak ditemukan           | Tidak ada perbaikan khusus untuk bagian ini.                                             |
| Instansiasi repository atau Dio di presentation  | Tidak ditemukan di widget | `AuthRepository()` dibuat melalui provider Riverpod, sedangkan Dio dibuat di layer data. |

## Kesimpulan

Struktur proyek sudah cukup terpisah, tetapi beberapa halaman masih digabung dan akses Firebase masih dilakukan langsung di halaman. Refactor selanjutnya adalah memisahkan halaman, kontrak repository, dan akses Firebase agar kode lebih rapi dan mudah dikembangkan.

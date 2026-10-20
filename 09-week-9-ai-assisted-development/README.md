# Week 9 - AI-assisted Offline Notes

## Fitur

Aplikasi Flutter offline-first untuk mencatat notes:

- tambah, edit, hapus, dan lihat detail note;
- pencarian judul case-insensitive;
- empty state untuk query kosong dan query tidak cocok;
- penyimpanan notes di SQLite;
- cache posts dari REST API;
- status sinkronisasi, dark mode, dan preferensi terakhir dibuka.

## Prompt

Prompt utama:

> Peran: senior Flutter dev. Konteks: feature-first, Riverpod, SQLite+Dio.
> Tambah search judul notes dan empty state. Jangan ubah arsitektur, maksimal
> 80 baris. Tambahkan tiga test, cek import domain, validasi API, jalankan
> `flutter analyze`, dan uji query kosong/cocok/tidak cocok.

Prompt mentah dan output awal ada di [docs/ai-log.md](docs/ai-log.md).
Usulan arsitektur ada di
[docs/feature-first-clean-architecture.md](docs/feature-first-clean-architecture.md).

## Stack

- Flutter/Dart
- Riverpod 3.4.3
- SQLite dengan `sqflite` 2.4.4
- Dio 5.11.1
- GoRouter
- `flutter_test`

Struktur aktif:

```text
week5_offline_notes/lib/
├── app/app.dart
├── core/failures.dart
├── features/notes/
│   ├── domain/
│   ├── data/
│   └── presentation/
├── routes.dart
└── main.dart
```

Domain note tidak mengimpor Flutter, Riverpod, Dio, SQLite, atau `path`.

## Cara menjalankan

```bash
cd 09-week-9-ai-assisted-development/week5_offline_notes
flutter pub get
flutter run -d linux
```

Ganti `-d linux` dengan device yang tersedia dari `flutter devices`.

## Cara menguji dan hasil

```bash
cd 09-week-9-ai-assisted-development/week5_offline_notes
flutter analyze
flutter test
```

Hasil terakhir:

```text
flutter analyze: No issues found!
flutter test: 9 tests passed
```

Uji manual:

1. Query kosong: semua notes tampil; database kosong menampilkan
   `Belum ada catatan.`
2. Query cocok, misalnya `Belanja`: hanya judul yang cocok tampil.
3. Query tidak cocok, misalnya `KuliahXYZ`: tampil
   `Tidak ada catatan yang cocok.`

Screenshot run disimpan di [screenshots/](screenshots/).

## Tabel keputusan saran AI

| Saran AI | Terima/Tolak | Alasan teknis | Bukti grep/test |
|---|---|---|---|
| Search judul dengan filter lokal | Terima | Dataset notes sudah dimuat; tidak menambah query SQLite | Test search cocok/tidak cocok lulus |
| Empty state query kosong vs tidak cocok | Terima | Feedback pengguna lebih jelas | Widget test menemukan teks empty state |
| Gunakan `StateProvider<String>` | Tolak | Tidak tersedia pada Riverpod 3.4.3 | `flutter analyze`: `StateProvider isn't defined` |
| Ganti ke `NotifierProvider` | Terima | API valid dan tetap ringan | Analyze nol isu; 9 test lulus |
| Entity menangani map SQLite | Tolak | Domain menjadi terikat persistence | Grep domain tidak menemukan `sqflite`/`path` |
| Pisahkan entity, model, datasource, repository | Terima | Domain murni dan datasource dapat diuji terpisah | Analyze dan fake repository lulus |
| Use case untuk semua operasi CRUD | Tolak sebagian | Wrapper tipis akan over-engineering | Use case hanya dibuat untuk get/add |
| Ignore seluruh minggu 9 kecuali `lib`/`test` | Tolak sebagian | README/docs/screenshots harus dapat di-push | `.gitignore` mengecualikan deliverable |

## Refleksi

### Halusinasi AI dan pembuktiannya

Halusinasi yang ditemukan adalah penggunaan `StateProvider`. Dependency aktual
adalah Riverpod 3.4.3, dan analyzer membuktikan:

```text
error: The function 'StateProvider' isn't defined
```

Bukti batas domain:

```bash
grep -RInE 'package:flutter|package:dio|package:sqflite|package:path' \
  lib/features/notes/domain
```

Perintah tersebut tidak menghasilkan output. Setelah memakai `NotifierProvider`,
`flutter analyze` menghasilkan `No issues found!` dan `flutter test` lulus.

### Prompt paling membantu dan perubahan

Bagian paling membantu adalah instruksi untuk memeriksa import domain, validasi
API package, menjalankan analyzer sampai nol warning, dan menulis test sukses/
gagal. Saya mengubah output awal dengan mengganti API Riverpod, memindahkan
entity/filter ke domain, memisahkan model SQLite-datasource-repository,
menambahkan DI feature notes, menambah widget test empty state, serta
memisahkan router dan bootstrap app.

### Refactor terhadap kode AI

Repository SQLite yang semula mencampur kontrak, query, mapping, dan entity
dipecah menjadi `NoteRepository` interface, `NoteModel`,
`NotesLocalDataSource`, dan `NoteRepositoryImpl`. Domain sekarang bebas
framework/storage dan fake repository dapat digunakan tanpa SQLite.

### Keputusan terima/tolak paling sulit

Yang paling sulit adalah menerima sebagian Clean Architecture tanpa membuat
wrapper use case untuk setiap CRUD. Struktur penuh berguna untuk sinkronisasi,
cache policy, dan aturan bisnis, tetapi terlalu banyak boilerplate untuk notes
sederhana. Karena itu use case hanya dibuat untuk `get_notes` dan `add_note`;
operasi lain tetap melalui kontrak repository.

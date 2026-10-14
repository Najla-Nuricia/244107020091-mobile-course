# Week 8 — Mid-Project Review

**Nama:** Najla Nuricia Laudy
**Kelas:** TI-3F
**NIM:** 244107020091

## Status Review

Review tengah semester ini menggunakan kelanjutan project Minggu 5,
`week5_offline_notes`. Fokus review adalah kesiapan fondasi project sebelum
pengembangan fitur berikutnya: struktur data lokal, cache-first API, state
management Riverpod, routing GoRouter, serta pengujian.

Project Week 8 berada di [week5_offline_notes](./week5_offline_notes/).
Dokumentasi keputusan review berada di:

- [review-checklist.md](./docs/review-checklist.md)
- [ai-review-vs-keputusan.md](./docs/ai-review-vs-keputusan.md)

## Fitur Utama

- Membuat, mengubah, menghapus, dan membaca catatan offline.
- Menyimpan catatan dan cache posts menggunakan SQLite.
- Menampilkan posts dari cache terlebih dahulu dan memperbaruinya dari API.
- Menandai catatan yang belum tersinkronkan.
- Toggle tema terang/gelap.
- Pengujian repository palsu, provider Riverpod, serialisasi model, dan widget.

## Struktur Project

```text
week5_offline_notes/
├── lib/
│   ├── data/
│   │   ├── local/          # Database dan model catatan
│   │   ├── models/         # Model API
│   │   ├── repositories/   # Akses data
│   │   └── providers.dart  # Dependency injection/state
│   ├── pages/
│   ├── widgets/
│   └── main.dart
└── test/
```

## Stack

- Flutter dan Dart
- Riverpod
- GoRouter
- Dio
- SQLite melalui `sqflite`
- Shared Preferences
- Flutter Test

## Cara Menjalankan

```sh
cd 08-week-8-mid-project-review/week5_offline_notes
flutter pub get
flutter run
```

## Bukti Verifikasi

Perintah berikut dijalankan dari folder project:

```sh
flutter analyze
# No issues found!

flutter test
# All tests passed! (5 tests)
```

CI repository juga menjalankan analyzer, formatter, dan test untuk perubahan
yang menyentuh project Week 8 melalui
[week8-ci.yml](../../.github/workflows/week8-ci.yml).

## Status Issue dan Pull Request

Perubahan Week 8 disiapkan sebagai satu unit review yang kecil dan terukur.
Issue dan Pull Request GitHub perlu dibuat/ditautkan saat pekerjaan kolaboratif
dilakukan; dokumentasi ini tidak mengklaim issue atau PR yang belum dibuat.

| Item | Status |
| --- | --- |
| Audit riwayat dan working tree | Selesai |
| `flutter analyze` | Lulus |
| `flutter test` | Lulus, 5 test |
| Dokumentasi review AI | Selesai |
| Issue + PR sejawat | Menunggu dibuat di GitHub |
| Screenshot manual | Menunggu pengambilan dari emulator |
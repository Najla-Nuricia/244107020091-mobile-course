# Week 7 — Clean Architecture

Nama: Najla Nuricia Laudy  
Kelas: TI-3F  
NIM: 244107020091

Refactor Week 7 diterapkan pada proyek `campus_notify` di folder ini dengan
memisahkan kode berdasarkan fitur dan layer.

## Struktur Proyek

```text
campus_notify/lib/
├── core/
│   ├── failures.dart
│   ├── providers.dart
│   └── network/
│       ├── api_client.dart
│       └── api_errors.dart
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/auth_session.dart
│   │   │   ├── failures/auth_failure.dart
│   │   │   └── repositories/
│   │   │       ├── auth_repository.dart
│   │   │       └── session_store.dart
│   │   ├── data/
│   │   │   ├── datasources/token_store.dart
│   │   │   └── repositories/auth_repository_impl.dart
│   │   └── presentation/
│   │       ├── pages/login_page.dart
│   │       └── providers/auth_providers.dart
│   ├── announcements/
│   │   └── presentation/pages/
│   │       ├── announcement_page.dart
│   │       └── home_page.dart
│   └── notifications/
│       ├── data/push_service.dart
│       └── presentation/providers/notification_providers.dart
├── main.dart
└── routes.dart
```

## Pembagian Tanggung Jawab

- `domain` mendefinisikan entitas dan interface repository. Domain tidak
  bergantung pada Flutter, Dio, maupun secure storage.
- `data` mengimplementasikan repository, penyimpanan token, akses API, dan
  integrasi Firebase.
- `presentation` berisi halaman dan provider/notifier fitur. Halaman tidak
  mengakses Firebase, Dio, atau secure storage langsung.
- `core` berisi failure bersama, provider lintas fitur, serta utilitas jaringan.
- `routes.dart` mendaftarkan halaman fitur dan menjaga helper route/deep link.

## Hasil Pemeriksaan Pelanggaran

`lib/pages` dan `lib/widgets` bukan struktur yang digunakan lagi. Pencarian
akses langsung dari widget dapat diarahkan ke `lib/features/**/presentation`:

| Pemeriksaan | Hasil |
| --- | --- |
| `Dio(`, `http.`, `openDatabase`, `SharedPreferences.getInstance`, `FlutterSecureStorage` di presentation | Tidak ditemukan |
| `DateFormat`, `jsonDecode`, `.toIso8601String` di presentation | Tidak ditemukan |
| Instansiasi repository atau `Dio(BaseOptions` di halaman | Tidak ditemukan; wiring repository ada di provider auth dan Dio di `core/network` |

Token FCM yang ditampilkan di `HomePage` kini dibaca melalui service dan
`deviceTokenProvider`; widget hanya merender state provider.

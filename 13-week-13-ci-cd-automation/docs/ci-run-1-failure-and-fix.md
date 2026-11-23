# Run #1 — kegagalan dan perbaikan

- Run #1: https://github.com/Najla-Nuricia/244107020091-mobile-course/actions/runs/45171971272 — commit `9cffeec`
- Run #2: https://github.com/Najla-Nuricia/244107020091-mobile-course/actions/runs/45172722608 — commit `367d182` (gagal dengan penyebab yang sama)
- Hasil: **failure** pada step `flutter analyze --fatal-infos` (exit 1). Step `flutter test`, build, dan upload artefak tidak jalan.

## Root cause

`subosito/flutter-action@v2` dengan `channel: stable` menginstall Flutter **3.50.1** (Dart 3.14.0), sedangkan verifikasi lokal memakai Flutter **3.47.1** (Dart 3.13.1). Pada Flutter 3.50, `package:flutter/material.dart` ditandai deprecated:

```
info • 'package:flutter/material.dart' is deprecated and shouldn't be used.
       Use package:material_ui/material_ui.dart instead.
       This feature was deprecated after v3.47.0-0.0.pre.
       • deprecated_member_use
```

Karena workflow memakai `--fatal-infos`, 6 info tersebut membuat analyze gagal (5 file di `lib/`, 1 di `test/widget_test.dart`).

## Perbaikan

- Tambah dependency `material_ui: ^1.11.1` (pustaka Material resmi yang direkomendasikan Flutter 3.50).
- Ganti 6 import `package:flutter/material.dart` → `package:material_ui/material_ui.dart`.
- `--fatal-infos` **tetap dipakai**; tidak ada lint/pemeriksaan yang dinonaktifkan.

## Verifikasi ulang

| Pemeriksaan | Flutter 3.47.1 | Flutter 3.50.1 (versi CI) |
| --- | --- | --- |
| `dart format --output=none --set-exit-if-changed .` | 34 file, 0 berubah | |
| `flutter analyze --fatal-infos` | No issues found | No issues found |
| `flutter test --coverage` | 27/27 | 27/27 |
| `flutter build apk --release` |  59,0 MB | — |
| `flutter build appbundle --release` | 57,8 MB | — |

Build lokal memakai Flutter 3.47.1; step build di CI perlu diverifikasi ulang setelah push perbaikan.

## Run #3 dan #4 — dibatalkan

Run #3 (commit `3efb8d5`) dan #4 (commit `dab190f`) dibatalkan (status `cancelled`) karena ada push baru saat run masih berjalan. Workflow memakai `concurrency.cancel-in-progress: true`, sehingga run lama otomatis dibatalkan.

## Run #5 — kegagalan build Android

- Run #5: https://github.com/Najla-Nuricia/244107020091-mobile-course/actions/runs/45175598994 — commit `ffa7bc4`
- `flutter pub get`, format, analyze, dan test lolos. `flutter build apk --release` gagal.
- Root cause: Flutter 3.50.1 membutuhkan Android Gradle Plugin minimal **9.1.1** dan Gradle minimal **9.5.0**. Project masih memakai AGP `9.1.0` dan wrapper Gradle `9.3.1`.
- Perbaikan: `android/settings.gradle.kts` → AGP `9.1.1`; `android/gradle/wrapper/gradle-wrapper.properties` → Gradle `9.5.0`.

## Run #6 — sukses

- Run: https://github.com/Najla-Nuricia/244107020091-mobile-course/actions/runs/45179568958
- Commit: `6175595`
- Status: **success**. Semua step lolos, termasuk `flutter build apk --release`, `flutter build appbundle --release`, dan `actions/upload-artifact@v4`.
- Artefak: `android-builds` (84.838.898 byte), tidak expired, retensi 7 hari.

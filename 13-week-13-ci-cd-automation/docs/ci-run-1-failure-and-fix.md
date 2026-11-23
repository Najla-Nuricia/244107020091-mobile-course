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

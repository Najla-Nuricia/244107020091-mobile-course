# AI Log

## Prompt mentah

> Peran: senior Flutter dev  
> Konteks: feature-first, Riverpod, SQLite+Dio  
> Tugas: tambah search judul notes + empty state  
> Batas: jangan ubah arsitektur, maks 80 baris  
> Output: kode + 3 test case + cara uji impan prompt mentah dan output awal AI ke `docs/ai-log.md`.  

## Output awal AI

Target paling dekat adalah `09-week-9-ai-assisted-development/week5_offline_notes`.
Perubahan dirancang memakai provider query dan helper filter judul, tanpa mengubah
repository SQLite/Dio atau menambahkan dependensi.

## Bug/halusinasi yang ditemukan dan bukti

Percobaan awal memakai `StateProvider`, tetapi API itu tidak tersedia pada
Riverpod `3.4.3`. Buktinya:

```text
flutter analyze
error: The function 'StateProvider' isn't defined
.../lib/data/providers.dart:43:34
```

`dart pub deps --style=compact` membuktikan versi `flutter_riverpod 3.4.3`;
setelah diganti ke `NotifierProvider`, `flutter analyze` menghasilkan `No issues
found!`, dan test search lulus. Grep pada `lib/data/local/note.dart` juga tidak
menemukan `flutter`, `dio`, atau `sqflite`.

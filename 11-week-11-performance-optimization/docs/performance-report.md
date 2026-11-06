# Performance Report

## Project dan skenario

Profiling dilakukan pada project
[`week5_offline_notes`](../week5_offline_notes/) menggunakan Flutter DevTools
mode profile. Skenario yang digunakan adalah membuka daftar catatan, scroll
cepat, membuka detail, kembali ke daftar, lalu melakukan pull-to-refresh.

## Baseline metrics

Baseline direkam sebelum optimasi. Screenshot tersedia di
[`before-profiling.png`](../screenshots/before-profiling.png).

| Metrik | Baseline |
|---|---:|
| FPS rata-rata yang terlihat | 113 FPS |
| Frame jank yang terlihat | 9 bar jank pada rentang frame 1193-1207 |
| Frame terpilih | 1119 |
| Status frame terpilih | UI Jank Detected |
| Fase terlama | Build |
| Memory | Heap relatif stabil pada Memory chart, tidak terlihat tren naik terus |

Angka jank di atas adalah jumlah bar merah yang terlihat pada screenshot
baseline, bukan total seluruh sesi rekaman.

## Temuan profiling

1. **Build/rebuild menjadi bottleneck.** Frame Analysis baseline menampilkan
   `UI Jank Detected` dan `Build was the longest UI phase`.
2. **List membuat seluruh item sekaligus.** Implementasi baseline menggunakan
   `.map(...).toList()` di dalam `Column`, sehingga biaya build dan layout
   meningkat saat daftar bertambah.
3. **Request posts dapat berulang.** Fungsi cache-first membaca SQLite, tetapi
   tetap menjalankan fetch jaringan saat provider di-invalidate pada refresh.
4. **Tidak ada indikasi memory leak.** Heap chart relatif stabil setelah
   navigasi berulang. Controller yang digunakan sudah dibuang melalui
   `dispose()`.

Screenshot hasil sesudah optimasi:
[`after-profiling.png`](../screenshots/after-profiling.png).

## Optimasi yang diterapkan

### 1. Riverpod `select`

Provider untuk mode tema, jumlah catatan dirty, dan waktu terakhir dibuka
menggunakan `select`. Widget hanya rebuild ketika nilai yang dipakai berubah,
bukan ketika keseluruhan `AsyncValue` berubah.

### 2. `ListView.builder`

Daftar catatan diekstrak ke widget `_NoteItems` dan dibangun dengan
`ListView.builder`. Ini menghindari pembuatan seluruh daftar melalui
`.map(...).toList()` dan mempertahankan pola lazy building.

### 3. `RepaintBoundary`

Setiap card catatan dibungkus `RepaintBoundary` agar repaint satu item tidak
memaksa seluruh area daftar dicat ulang.

### 4. Const dan ekstraksi widget

Widget statis tetap menggunakan constructor `const`, sedangkan daftar catatan
dipisahkan dari `NotesPage` ke `_NoteItems` agar subtree lebih terisolasi.

## Hasil verifikasi

Screenshot sesudah optimasi menunjukkan frame terpilih 1427 dengan:

- `No suggestions for this frame - no jank detected`;
- Raster phase **3,9 ms**;
- tidak ada indikator jank pada frame yang dipilih.

Perbandingan metrik yang terlihat:

| Metrik | Sebelum | Sesudah |
|---|---:|---:|
| FPS rata-rata terlihat | 113 FPS | 113 |
| Frame terpilih | 1119 | 1427 |
| Status jank | UI Jank Detected | No jank detected |
| Memory | Relatif stabil | Tidak terlihat penumpukan objek |


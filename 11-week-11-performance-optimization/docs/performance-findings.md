# Performance Findings

## Sumber profiling

Profiling dilakukan menggunakan Flutter DevTools Performance pada mode profile
dengan skenario membuka daftar, scrolling, membuka detail, kembali ke daftar,
dan pull-to-refresh.

Pada frame yang dipilih di DevTools terlihat:

- status **UI Jank Detected**;
- fase **Build** menjadi fase UI terlama;
- beberapa bar **Jank (slow frame)** pada Frame Chart;
- DevTools menampilkan frame `1119` sebagai frame yang dianalisis.

## Temuan 1 - Widget rebuild berlebih

**Bukti profiling:** Frame Analysis menandai **UI Jank Detected** dan
menyatakan bahwa **Build was the longest UI phase**. Ini menunjukkan pekerjaan
build menjadi bottleneck pada frame tersebut.

**Penyebab pada kode:** `NotesPage` mengamati beberapa provider sekaligus
(`notesProvider`, `postsProvider`, `darkModeProvider`,
`dirtyNotesCountProvider`, dan `lastOpenedProvider`). Perubahan salah satu
provider dapat membangun ulang subtree halaman daftar yang besar, termasuk
AppBar, search field, status sinkronisasi, dan daftar catatan.

**Dampak:** waktu UI thread meningkat dan frame dapat melewati budget 16,67 ms
untuk 60 FPS, sehingga muncul frame jank.

## Temuan 2 - List belum menggunakan builder

**Bukti profiling:** Frame Chart menunjukkan frame lambat ketika skenario
scrolling dijalankan. Pada kode baseline, daftar catatan dibuat dengan
`.map(...).toList()` di dalam `Column` (`lib/app/app.dart`), sehingga seluruh
item dibuat dan dilayout sekaligus, bukan hanya item yang berada di viewport.

**Dampak:** biaya build dan layout bertambah seiring jumlah catatan. Saat
scrolling cepat, pekerjaan layout yang panjang dapat memperbesar durasi frame
dan memicu jank.

**Perbaikan yang dipilih:** gunakan `ListView.builder` dan ekstrak item daftar
ke widget terpisah agar pembuatan item bersifat lazy.

## Temuan 3 - Request API berulang saat cache tersedia

**Bukti kode dan skenario:** `loadPostsCacheFirst` memang membaca
`cached_posts`, tetapi selalu menjalankan `repo.fetchPosts()` pada background
setiap kali `postsProvider` dievaluasi. Provider tersebut di-invalidate saat
pull-to-refresh, sehingga satu tindakan refresh kembali menghasilkan request
HTTP walaupun cache lokal sudah tersedia.

**Dampak:** request jaringan, decoding JSON, dan penulisan SQLite dilakukan
berulang. Selain menambah penggunaan jaringan dan CPU, callback
`onPostsUpdated` meng-invalidate provider lagi setelah data berhasil disimpan,
yang membuat alur pemuatan berjalan kembali.

**Perbaikan yang dipilih:** pertahankan cache-first untuk tampilan awal, tetapi
tambahkan aturan stale-while-revalidate/TTL atau deduplikasi request agar
refresh dalam interval singkat tidak mengirim request identik berulang.

## Temuan yang tidak diklaim

Trace yang tersedia tidak menunjukkan bukti cukup untuk menyatakan adanya
`image decode` besar pada Raster Thread atau memory leak. Keduanya perlu
diverifikasi masing-masing melalui Timeline Raster dan perbandingan Heap
Snapshot sebelum/sesudah navigasi lima kali.

## Hasil memory profiling

Heap chart DevTools setelah pengambilan snapshot dan navigasi daftar-detail
berulang menunjukkan penggunaan heap yang relatif stabil; tidak terlihat tren
naik terus-menerus yang menunjukkan objek halaman menumpuk.

Inspeksi lifecycle juga menunjukkan:

- controller editor pada [`app.dart`](../week5_offline_notes/lib/app/app.dart)
  dibuang setelah dialog selesai;
- controller editor detail pada
  [`note_detail_page.dart`](../week5_offline_notes/lib/pages/note_detail_page.dart)
  dibuang setelah dialog selesai;
- controller chat pada
  [`chat_screen.dart`](../week5_offline_notes/lib/features/chat/chat_screen.dart)
  dibuang di `State.dispose()`.

Kesimpulan: tidak ditemukan memory leak yang memerlukan perubahan kode.
Listener, stream subscription, dan animation controller juga tidak digunakan
oleh halaman daftar/detail yang diuji, sehingga tidak ada `dispose()` tambahan
yang diperlukan.

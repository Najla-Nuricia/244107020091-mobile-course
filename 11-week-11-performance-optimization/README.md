# Minggu 11 - Performance Optimization

Project praktikum:
[`week5_offline_notes`](./week5_offline_notes/).

## Dokumentasi

- [Performance report](./docs/performance-report.md)
- [Performance findings](./docs/performance-findings.md)
- [Baseline Flame Chart](./screenshots/before-profiling.png)
- [After optimization Flame Chart](./screenshots/after-profiling.png)

## Optimasi

Optimasi yang diterapkan:

- Riverpod `select` untuk mengurangi rebuild;
- `ListView.builder` untuk lazy building daftar;
- `RepaintBoundary` untuk mengisolasi repaint item;
- `const` constructor dan ekstraksi widget untuk subtree statis.

## Validasi

- [test](./test.png)
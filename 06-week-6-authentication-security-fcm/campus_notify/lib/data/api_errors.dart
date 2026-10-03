import 'package:dio/dio.dart';

String apiErrorMessage(DioException error) {
  if (error.response?.statusCode == 401) {
    return 'Sesi berakhir. Silakan masuk kembali.';
  }

  if (error.response?.statusCode case final statusCode?
      when statusCode >= 500) {
    return 'Layanan sedang bermasalah. Coba lagi nanti.';
  }

  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout => 'Koneksi terlalu lama. Coba lagi.',
    DioExceptionType.connectionError =>
      'Tidak ada koneksi internet. Periksa jaringanmu.',
    DioExceptionType.cancel => 'Permintaan dibatalkan.',
    DioExceptionType.badCertificate => 'Koneksi tidak aman. Coba lagi nanti.',
    DioExceptionType.badResponse =>
      'Permintaan gagal. Periksa data lalu coba lagi.',
    DioExceptionType.unknown => 'Terjadi gangguan jaringan. Coba lagi.',
  };
}

import 'package:campus_notify/data/api_errors.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dioError({
  DioExceptionType type = DioExceptionType.unknown,
  int? statusCode,
}) {
  final request = RequestOptions(path: '/test');
  return DioException(
    requestOptions: request,
    type: type,
    response: statusCode == null
        ? null
        : Response(requestOptions: request, statusCode: statusCode),
  );
}

void main() {
  test('maps unauthorized responses to a sign-in message', () {
    expect(
      apiErrorMessage(_dioError(statusCode: 401)),
      'Sesi berakhir. Silakan masuk kembali.',
    );
  });

  test('maps connection timeouts to a retry message', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      expect(
        apiErrorMessage(_dioError(type: type)),
        'Koneksi terlalu lama. Coba lagi.',
      );
    }
  });

  test('maps offline errors without exposing the raw exception', () {
    expect(
      apiErrorMessage(_dioError(type: DioExceptionType.connectionError)),
      'Tidak ada koneksi internet. Periksa jaringanmu.',
    );
  });
}

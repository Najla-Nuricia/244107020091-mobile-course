import 'package:dio/dio.dart';

import 'auth_repository.dart';
import 'token_store.dart';

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

Dio buildApiClient(TokenStore store, AuthRepository auth, {String? baseUrl}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl ?? _apiBaseUrl));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = 'Bearer $access';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          final refresh = await store.readRefresh();
          if (refresh == null) return handler.next(e);
          try {
            final renewed = await auth.refresh(refresh);
            await store.save(access: renewed, refresh: refresh);
            final retry = await dio.fetch(
              e.requestOptions..headers['Authorization'] = 'Bearer $renewed',
            );
            return handler.resolve(retry);
          } catch (_) {
            await store.clear(); // refresh ikut mati -> paksa login ulang
          }
        }
        handler.next(e);
      },
    ),
  );
  return dio;
}

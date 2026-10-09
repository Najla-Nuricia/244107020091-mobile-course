import 'package:dio/dio.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/session_store.dart';

const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');
const _retriedAfterRefresh = 'retriedAfterRefresh';

Dio buildApiClient(
  SessionStore store,
  AuthRepository auth, {
  String? baseUrl,
  Future<void> Function()? onSessionExpired,
}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl ?? _apiBaseUrl));
  Future<void> expireSession() async {
    await store.clear();
    await onSessionExpired?.call();
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final access = await store.readAccess();
        if (access != null) {
          options.headers['Authorization'] = '******';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode != 401) {
          return handler.next(e);
        }

        if (e.requestOptions.extra[_retriedAfterRefresh] == true) {
          await expireSession();
          return handler.next(e);
        }

        final refresh = await store.readRefresh();
        if (refresh == null || refresh.isEmpty) {
          await expireSession();
          return handler.next(e);
        }

        late final String renewed;
        try {
          renewed = await auth.refresh(refresh);
        } catch (_) {
          await expireSession();
          return handler.next(e);
        }

        await store.save(access: renewed, refresh: refresh);
        final retryOptions = e.requestOptions.copyWith(
          extra: {...e.requestOptions.extra, _retriedAfterRefresh: true},
          headers: {
            ...e.requestOptions.headers,
            'Authorization': '******',
          },
        );

        try {
          return handler.resolve(await dio.fetch<Object?>(retryOptions));
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      },
    ),
  );
  return dio;
}

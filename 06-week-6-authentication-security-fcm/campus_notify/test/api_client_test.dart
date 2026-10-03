import 'dart:typed_data';

import 'package:campus_notify/data/api_client.dart';
import 'package:campus_notify/data/auth_repository.dart';
import 'package:campus_notify/data/token_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemorySessionStore implements SessionStore {
  String? access = 'expired-access';
  String? refresh = 'valid-refresh';

  @override
  Future<void> save({required String access, required String refresh}) async {
    this.access = access;
    this.refresh = refresh;
  }

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository({this.fail = false});

  final bool fail;
  int refreshCount = 0;

  @override
  Future<String> refresh(String refreshToken) async {
    refreshCount++;
    if (fail) throw Exception('refresh expired');
    return 'fresh-access';
  }
}

class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.statuses);

  final List<int> statuses;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final status =
        statuses[requests.length <= statuses.length
            ? requests.length - 1
            : statuses.length - 1];
    final body = status == 200 ? '{"ok":true}' : '{"error":"unauthorized"}';
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('retries a 401 exactly once with the refreshed access token', () async {
    final store = _MemorySessionStore();
    final auth = _FakeAuthRepository();
    final adapter = _StatusAdapter([401, 200]);
    final dio = buildApiClient(store, auth, baseUrl: 'https://api.example.test')
      ..httpClientAdapter = adapter;
    addTearDown(() => dio.close(force: true));

    final response = await dio.get<Object?>('/profile');

    expect(response.statusCode, 200);
    expect(adapter.requests, hasLength(2));
    expect(auth.refreshCount, 1);
    expect(
      adapter.requests[0].headers['Authorization'],
      'Bearer expired-access',
    );
    expect(adapter.requests[1].headers['Authorization'], 'Bearer fresh-access');
    expect(store.access, 'fresh-access');
  });

  test(
    'clears the session and signals logout when refresh has expired',
    () async {
      final store = _MemorySessionStore();
      final auth = _FakeAuthRepository(fail: true);
      final adapter = _StatusAdapter([401]);
      var logoutCount = 0;
      final dio = buildApiClient(
        store,
        auth,
        baseUrl: 'https://api.example.test',
        onSessionExpired: () async => logoutCount++,
      )..httpClientAdapter = adapter;
      addTearDown(() => dio.close(force: true));

      await expectLater(
        dio.get<Object?>('/profile'),
        throwsA(isA<DioException>()),
      );

      expect(auth.refreshCount, 1);
      expect(adapter.requests, hasLength(1));
      expect(store.access, isNull);
      expect(store.refresh, isNull);
      expect(logoutCount, 1);
    },
  );

  test('does not refresh repeatedly when the retry also returns 401', () async {
    final store = _MemorySessionStore();
    final auth = _FakeAuthRepository();
    final adapter = _StatusAdapter([401, 401]);
    var logoutCount = 0;
    final dio = buildApiClient(
      store,
      auth,
      baseUrl: 'https://api.example.test',
      onSessionExpired: () async => logoutCount++,
    )..httpClientAdapter = adapter;
    addTearDown(() => dio.close(force: true));

    await expectLater(
      dio.get<Object?>('/profile'),
      throwsA(isA<DioException>()),
    );

    expect(adapter.requests, hasLength(2));
    expect(auth.refreshCount, 1);
    expect(logoutCount, 1);
    expect(store.access, isNull);
  });
}

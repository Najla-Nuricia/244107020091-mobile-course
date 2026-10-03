import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'providers/auth_provider.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  registerBackgroundHandler();
  runApp(const ProviderScope(child: MyApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRefresh = ref.watch(authRouterRefreshProvider);
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      return authRouteRedirect(
        isAuthenticated: authState.asData?.value ?? false,
        isLoading: authState.isLoading,
        uri: state.uri,
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.announcementPath,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AnnouncementPage(id: id);
        },
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appRouter = ref.read(routerProvider);
      unawaited(
        ref
            .read(pushServiceProvider)
            .initialize(navigate: appRouter.go)
            .then(
              (_) => ref.read(pushServiceProvider).subscribeToAnnouncements(),
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hadirin',
      routerConfig: ref.watch(routerProvider),
    );
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    await ref
        .read(authStateProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);
    if (!mounted || ref.read(authStateProvider).asData?.value != true) return;

    final requestedRoute = GoRouterState.of(context)
        .uri
        .queryParameters['from'];
    final destination =
        requestedRoute != null &&
            requestedRoute.startsWith('/') &&
            !requestedRoute.startsWith('//')
        ? requestedRoute
        : AppRoutes.home;
    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final error = authState.error;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                const Text('Masuk', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Kata sandi'),
                ),
                if (authState.hasError) ...[
                  const SizedBox(height: 12),
                  Text(
                    error is String ? error : 'Tidak dapat masuk. Coba lagi.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: authState.isLoading ? null : _login,
                  child: Text(authState.isLoading ? 'Memproses...' : 'Masuk'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _tokenPreview = 'Memuat token...';
  late final _tokenRefreshSubscription = FirebaseMessaging
      .instance
      .onTokenRefresh
      .listen(_showTokenPreview);

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (mounted && token != null) _showTokenPreview(token);
    } catch (_) {
      if (mounted) setState(() => _tokenPreview = 'Token tidak tersedia');
    }
  }

  void _showTokenPreview(String token) {
    if (!mounted) return;
    setState(() {
      _tokenPreview = token.length > 12 ? token.substring(0, 12) : 'Tersedia';
    });
  }

  @override
  void dispose() {
    _tokenRefreshSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Home'),
            const SizedBox(height: 8),
            Text('Token FCM: $_tokenPreview'),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.announcement('3')),
              icon: const Icon(Icons.campaign_outlined),
              label: const Text('Pengumuman terbaru'),
            ),
            TextButton.icon(
              onPressed: () => ref.read(authStateProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnouncementPage extends StatelessWidget {
  final String id;

  const AnnouncementPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Announcement ID: $id')));
  }
}

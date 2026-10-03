import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'messaging/push_service.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  registerBackgroundHandler();
  runApp(const ProviderScope(child: MyApp()));
}

final router = GoRouter(
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
      unawaited(
        ref
            .read(pushServiceProvider)
            .initialize(navigate: router.go)
            .then(
              (_) => ref.read(pushServiceProvider).subscribeToAnnouncements(),
            ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'Hadirin', routerConfig: router);
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Login')));
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

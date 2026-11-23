import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

Future<void> initMonitoring() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

Future<void> recordNonFatalProbe(String reason) async {
  await FirebaseCrashlytics.instance.recordError(
    StateError(reason),
    StackTrace.current,
    fatal: false,
    reason: 'monitoring_probe',
  );
}

Future<void> logBetaFeedback({required String screenName}) async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'beta_feedback_sent',
    parameters: {'screen_name': screenName},
  );
}

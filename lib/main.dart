import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'screens/auth_gate.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    // Android emulators lack genuine Play Integrity attestation, which makes
    // the reCAPTCHA-based abuse protection on email/password auth fail with
    // CONFIGURATION_NOT_FOUND. This flag is meant exactly for dev/test
    // environments like this.
    await FirebaseAuth.instance.setSettings(
      appVerificationDisabledForTesting: true,
    );
  }

  runApp(BengkelKuApp(appProvider: AppProvider()));
}

class BengkelKuApp extends StatelessWidget {
  final AppProvider appProvider;

  const BengkelKuApp({super.key, required this.appProvider});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appProvider,
      child: MaterialApp(
        title: 'BengkelKu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}

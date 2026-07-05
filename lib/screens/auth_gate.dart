import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'auth/login_screen.dart';
import 'bengkel/setup_bengkel_screen.dart';
import 'role_shell.dart';

/// Root of the widget tree below [MaterialApp]. Reactively swaps between
/// login, bengkel-profile onboarding, and the normal role shell as the
/// signed-in account's auth/profile state changes — including mid-session
/// role switches, not just at cold start.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    if (!app.isLoggedIn) {
      return const LoginScreen();
    }

    if (app.profileLoading || app.profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (app.role == UserRole.bengkel && app.myBengkelId == null) {
      return const SetupBengkelScreen();
    }

    return const RoleShell();
  }
}

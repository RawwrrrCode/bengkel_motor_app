import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'bengkel/bengkel_shell.dart';
import 'user/user_shell.dart';

/// Renders the correct shell for the signed-in account's current role.
/// [AuthGate] guarantees a profile (and, for the bengkel role, a completed
/// bengkel setup) exists before this widget is ever reached.
class RoleShell extends StatelessWidget {
  const RoleShell({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    return app.role == UserRole.user ? const UserShell() : const BengkelShell();
  }
}

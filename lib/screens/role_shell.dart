import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import 'bengkel/bengkel_shell.dart';
import 'role_select_screen.dart';
import 'user/user_shell.dart';

class RoleShell extends StatelessWidget {
  const RoleShell({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    if (!app.roleChosen) {
      return const RoleSelectScreen();
    }

    return app.role == UserRole.user ? const UserShell() : const BengkelShell();
  }
}

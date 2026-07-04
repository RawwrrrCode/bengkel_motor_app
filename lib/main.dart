import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'screens/role_shell.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final appProvider = AppProvider();
  await appProvider.loadPersisted();

  runApp(BengkelKuApp(appProvider: appProvider));
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
        home: const RoleShell(),
      ),
    );
  }
}

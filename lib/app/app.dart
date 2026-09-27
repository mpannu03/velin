import 'package:material_ui/material_ui.dart';

import 'shell/app_shell.dart';
import 'theme/app_theme.dart';

class VelinApp extends StatelessWidget {
  const VelinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AppShell(
        child: Scaffold(
          body: Center(
            child: Text('Velin'),
          ),
        ),
      ),
    );
  }
}
import 'package:material_ui/material_ui.dart';
import 'package:velin/app/navigation/navigation.dart';

import 'theme/app_theme.dart';

class VelinApp extends StatelessWidget {
  const VelinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
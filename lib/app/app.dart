import 'package:material_ui/material_ui.dart';
import 'package:velin/app/effects/effects.dart';
import 'package:velin/app/navigation/navigation.dart';
import 'package:velin/core/di/injection.dart';
import 'package:velin/l10n/app_localizations.dart';

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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => AppEffectListener(
        controller: getIt<AppEffectController>(),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

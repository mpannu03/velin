import 'package:flutter/widgets.dart';
import 'package:velin/app/navigation/app_navigation.dart';

import 'package:velin/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension AppNavigationItemX on AppNavigationItem {
  String label(BuildContext context) {
    return switch (this) {
      AppNavigationItem.home => context.l10n.navigationHome,
      AppNavigationItem.reader => context.l10n.navigationReader,
      AppNavigationItem.edit => context.l10n.navigationEdit,
      AppNavigationItem.tools => context.l10n.navigationTools,
    };
  }
}
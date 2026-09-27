import 'package:material_ui/material_ui.dart';

abstract final class AppTypography {
  static const display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );

  static const title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
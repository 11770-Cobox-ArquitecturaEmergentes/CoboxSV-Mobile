import 'package:flutter/material.dart';

import 'package:cobox_sv_mobile/app/colors.dart';
import 'package:cobox_sv_mobile/app/typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      secondary: AppColors.secondary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.secondaryLight,
      onSecondaryContainer: AppColors.secondary,
      tertiary: AppColors.warning,
      onTertiary: AppColors.white,
      tertiaryContainer: AppColors.warningLight,
      error: AppColors.danger,
      onError: AppColors.white,
      errorContainer: AppColors.dangerLight,
      onErrorContainer: AppColors.danger,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      surfaceContainerHighest: AppColors.gray100,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.border,
      outlineVariant: AppColors.divider,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.background,
      cardTheme: _cardTheme(),
      appBarTheme: _appBarTheme(),
      bottomNavigationBarTheme: _bottomNavTheme(),
      navigationBarTheme: _navBarTheme(),
      floatingActionButtonTheme: _fabTheme(),
      inputDecorationTheme: _inputDecorationTheme(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      dialogTheme: _dialogTheme(),
      snackBarTheme: _snackBarTheme(),
      chipTheme: _chipTheme(),
      dividerTheme: _dividerTheme(),
      progressIndicatorTheme: _progressIndicatorTheme(),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      secondary: AppColors.secondary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.black,
      primaryContainer: AppColors.primary,
      onPrimaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.black,
      secondaryContainer: AppColors.secondary,
      onSecondaryContainer: AppColors.secondaryLight,
      tertiary: AppColors.warningLight,
      onTertiary: AppColors.black,
      tertiaryContainer: AppColors.warning,
      error: AppColors.dangerLight,
      onError: AppColors.black,
      errorContainer: AppColors.danger,
      onErrorContainer: AppColors.dangerLight,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkSurfaceContainer,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.darkText,
        displayColor: AppColors.darkText,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardTheme: _cardThemeDark(),
      appBarTheme: _appBarThemeDark(),
      bottomNavigationBarTheme: _bottomNavThemeDark(),
      navigationBarTheme: _navBarThemeDark(),
      floatingActionButtonTheme: _fabThemeDark(),
      inputDecorationTheme: _inputDecorationThemeDark(),
      elevatedButtonTheme: _elevatedButtonThemeDark(),
      outlinedButtonTheme: _outlinedButtonThemeDark(),
      textButtonTheme: _textButtonThemeDark(),
      dialogTheme: _dialogThemeDark(),
      snackBarTheme: _snackBarThemeDark(),
      chipTheme: _chipThemeDark(),
      dividerTheme: _dividerThemeDark(),
      progressIndicatorTheme: _progressIndicatorThemeDark(),
    );
  }

  static CardThemeData _cardTheme() {
    return CardThemeData(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      color: AppColors.surface,
    );
  }

  static AppBarTheme _appBarTheme() {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.text,
      titleTextStyle: AppTypography.textTheme.titleLarge!.copyWith(
        color: AppColors.text,
      ),
      iconTheme: const IconThemeData(color: AppColors.text),
    );
  }

  static BottomNavigationBarThemeData _bottomNavTheme() {
    return BottomNavigationBarThemeData(
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: AppTypography.textTheme.labelSmall!,
      unselectedLabelStyle: AppTypography.textTheme.labelSmall!,
    );
  }

  static NavigationBarThemeData _navBarTheme() {
    return NavigationBarThemeData(
      elevation: 0,
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primaryLight,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.textTheme.labelSmall!.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTypography.textTheme.labelSmall!.copyWith(
          color: AppColors.textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return const IconThemeData(color: AppColors.textSecondary, size: 24);
      }),
    );
  }

  static FloatingActionButtonThemeData _fabTheme() {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
      labelStyle: AppTypography.textTheme.bodyMedium!.copyWith(
        color: AppColors.textSecondary,
      ),
      hintStyle: AppTypography.textTheme.bodyMedium!.copyWith(
        color: AppColors.textTertiary,
      ),
      floatingLabelStyle: AppTypography.textTheme.bodyMedium!.copyWith(
        color: AppColors.primary,
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.textTheme.labelLarge!,
        disabledBackgroundColor: AppColors.gray200,
        disabledForegroundColor: AppColors.gray400,
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: AppColors.border),
        textStyle: AppTypography.textTheme.labelLarge!,
        disabledForegroundColor: AppColors.gray400,
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: AppTypography.textTheme.labelLarge!,
        disabledForegroundColor: AppColors.gray400,
      ),
    );
  }

  static DialogThemeData _dialogTheme() {
    return DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: AppColors.surface,
      titleTextStyle: AppTypography.textTheme.headlineSmall!.copyWith(
        color: AppColors.text,
      ),
      contentTextStyle: AppTypography.textTheme.bodyMedium!.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  static SnackBarThemeData _snackBarTheme() {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: AppColors.gray800,
      contentTextStyle: AppTypography.textTheme.bodyMedium!.copyWith(
        color: AppColors.white,
      ),
      actionTextColor: AppColors.primaryLight,
    );
  }

  static ChipThemeData _chipTheme() {
    return ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      labelStyle: AppTypography.textTheme.labelMedium!,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      selectedColor: AppColors.primaryLight,
      backgroundColor: AppColors.gray100,
    );
  }

  static DividerThemeData _dividerTheme() {
    return DividerThemeData(
      color: AppColors.divider,
      space: 1,
      thickness: 1,
    );
  }

  static ProgressIndicatorThemeData _progressIndicatorTheme() {
    return ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.gray200,
      circularTrackColor: AppColors.gray200,
    );
  }

  static CardThemeData _cardThemeDark() {
    return CardThemeData(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      color: AppColors.darkSurface,
    );
  }

  static AppBarTheme _appBarThemeDark() {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkText,
      titleTextStyle: AppTypography.textTheme.titleLarge!.copyWith(
        color: AppColors.darkText,
      ),
      iconTheme: const IconThemeData(color: AppColors.darkText),
    );
  }

  static BottomNavigationBarThemeData _bottomNavThemeDark() {
    return BottomNavigationBarThemeData(
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.darkTextSecondary,
      selectedLabelStyle: AppTypography.textTheme.labelSmall!,
      unselectedLabelStyle: AppTypography.textTheme.labelSmall!,
    );
  }

  static NavigationBarThemeData _navBarThemeDark() {
    return NavigationBarThemeData(
      elevation: 0,
      backgroundColor: AppColors.darkSurface,
      indicatorColor: AppColors.darkSurfaceContainer,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.textTheme.labelSmall!.copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTypography.textTheme.labelSmall!.copyWith(
          color: AppColors.darkTextSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primaryLight, size: 24);
        }
        return const IconThemeData(color: AppColors.darkTextSecondary, size: 24);
      }),
    );
  }

  static FloatingActionButtonThemeData _fabThemeDark() {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.black,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationThemeDark() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dangerLight),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dangerLight, width: 2),
      ),
      labelStyle: AppTypography.textTheme.bodyMedium!.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      hintStyle: AppTypography.textTheme.bodyMedium!.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      floatingLabelStyle: AppTypography.textTheme.bodyMedium!.copyWith(
        color: AppColors.primaryLight,
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonThemeDark() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: AppTypography.textTheme.labelLarge!,
        disabledBackgroundColor: AppColors.darkSurfaceContainer,
        disabledForegroundColor: AppColors.darkTextSecondary,
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonThemeDark() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: AppColors.darkBorder),
        textStyle: AppTypography.textTheme.labelLarge!,
        disabledForegroundColor: AppColors.darkTextSecondary,
      ),
    );
  }

  static TextButtonThemeData _textButtonThemeDark() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: AppTypography.textTheme.labelLarge!,
        disabledForegroundColor: AppColors.darkTextSecondary,
      ),
    );
  }

  static DialogThemeData _dialogThemeDark() {
    return DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: AppColors.darkSurface,
      titleTextStyle: AppTypography.textTheme.headlineSmall!.copyWith(
        color: AppColors.darkText,
      ),
      contentTextStyle: AppTypography.textTheme.bodyMedium!.copyWith(
        color: AppColors.darkTextSecondary,
      ),
    );
  }

  static SnackBarThemeData _snackBarThemeDark() {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: AppColors.gray800,
      contentTextStyle: AppTypography.textTheme.bodyMedium!.copyWith(
        color: AppColors.darkText,
      ),
      actionTextColor: AppColors.primaryLight,
    );
  }

  static ChipThemeData _chipThemeDark() {
    return ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      labelStyle: AppTypography.textTheme.labelMedium!.copyWith(
        color: AppColors.darkText,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      selectedColor: AppColors.darkSurfaceContainer,
      backgroundColor: AppColors.darkSurface,
    );
  }

  static DividerThemeData _dividerThemeDark() {
    return DividerThemeData(
      color: AppColors.darkBorder,
      space: 1,
      thickness: 1,
    );
  }

  static ProgressIndicatorThemeData _progressIndicatorThemeDark() {
    return ProgressIndicatorThemeData(
      color: AppColors.primaryLight,
      linearTrackColor: AppColors.darkSurfaceContainer,
      circularTrackColor: AppColors.darkSurfaceContainer,
    );
  }
}

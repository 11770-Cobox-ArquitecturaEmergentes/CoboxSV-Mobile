import 'package:flutter/material.dart';

enum AppButtonSize { small, medium, large }

enum AppButtonVariant { primary, secondary, tertiary, outlined, text, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.disabled = false,
    this.fullWidth = false,
    this.size = AppButtonSize.medium,
    this.variant = AppButtonVariant.primary,
    this.elevation,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool loading;
  final bool disabled;
  final bool fullWidth;
  final AppButtonSize size;
  final AppButtonVariant variant;
  final double? elevation;

  bool get _isDisabled => disabled || loading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final sizeConfig = _sizeConfig(size, textTheme);
    final variantConfig = _variantConfig(variant, colorScheme, _isDisabled);

    final borderRadius = BorderRadius.circular(12);

    final content = _buildContent(
      sizeConfig,
      variantConfig,
      colorScheme,
    );

    final button = Material(
      borderRadius: borderRadius,
      color: variantConfig.backgroundColor,
      elevation: _isDisabled ? 0 : (elevation ?? variantConfig.elevation),
      shadowColor: variantConfig.shadowColor,
      surfaceTintColor: variantConfig.surfaceTintColor,
      child: InkWell(
        onTap: _isDisabled ? null : onPressed,
        borderRadius: borderRadius,
        splashColor: variantConfig.splashColor,
        highlightColor: variantConfig.highlightColor,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: sizeConfig.padding,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: variantConfig.border != null
                ? Border.all(color: variantConfig.border!)
                : null,
          ),
          child: content,
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildContent(
    _SizeConfig sizeConfig,
    _VariantConfig variantConfig,
    ColorScheme colorScheme,
  ) {
    final labelWidget = Text(
      label,
      style: sizeConfig.textStyle?.copyWith(
        color: variantConfig.foregroundColor,
      ),
      overflow: TextOverflow.ellipsis,
    );

    if (loading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: sizeConfig.loadingSize,
            height: sizeConfig.loadingSize,
            child: CircularProgressIndicator(
              strokeWidth: sizeConfig.loadingStrokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                variantConfig.foregroundColor,
              ),
            ),
          ),
          SizedBox(width: sizeConfig.spacing),
          labelWidget,
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTheme(
            data: IconThemeData(
              size: sizeConfig.iconSize,
              color: variantConfig.foregroundColor,
            ),
            child: icon!,
          ),
          SizedBox(width: sizeConfig.spacing),
          labelWidget,
        ],
      );
    }

    return Center(child: labelWidget);
  }

  _SizeConfig _sizeConfig(AppButtonSize size, TextTheme textTheme) {
    switch (size) {
      case AppButtonSize.small:
        return _SizeConfig(
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          iconSize: 16,
          loadingSize: 14,
          loadingStrokeWidth: 2,
          spacing: 6,
        );
      case AppButtonSize.medium:
        return _SizeConfig(
          textStyle: textTheme.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          iconSize: 18,
          loadingSize: 18,
          loadingStrokeWidth: 2.5,
          spacing: 8,
        );
      case AppButtonSize.large:
        return _SizeConfig(
          textStyle: textTheme.titleSmall,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          iconSize: 20,
          loadingSize: 20,
          loadingStrokeWidth: 2.5,
          spacing: 10,
        );
    }
  }

  _VariantConfig _variantConfig(
    AppButtonVariant variant,
    ColorScheme colorScheme,
    bool isDisabled,
  ) {
    switch (variant) {
      case AppButtonVariant.primary:
        return _VariantConfig(
          backgroundColor: isDisabled
              ? colorScheme.onSurface.withValues(alpha: 0.12)
              : colorScheme.primary,
          foregroundColor: isDisabled
              ? colorScheme.onSurface.withValues(alpha: 0.38)
              : colorScheme.onPrimary,
          splashColor: colorScheme.onPrimary.withValues(alpha: 0.12),
          highlightColor: colorScheme.onPrimary.withValues(alpha: 0.08),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: colorScheme.primary,
          border: null,
        );
      case AppButtonVariant.secondary:
        return _VariantConfig(
          backgroundColor: isDisabled
              ? colorScheme.onSurface.withValues(alpha: 0.12)
              : colorScheme.secondaryContainer,
          foregroundColor: isDisabled
              ? colorScheme.onSurface.withValues(alpha: 0.38)
              : colorScheme.onSecondaryContainer,
          splashColor: colorScheme.onSecondaryContainer.withValues(alpha: 0.12),
          highlightColor:
              colorScheme.onSecondaryContainer.withValues(alpha: 0.08),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: colorScheme.secondaryContainer,
          border: null,
        );
      case AppButtonVariant.tertiary:
        return _VariantConfig(
          backgroundColor: isDisabled
              ? colorScheme.onSurface.withValues(alpha: 0.12)
              : colorScheme.tertiaryContainer,
          foregroundColor: isDisabled
              ? colorScheme.onSurface.withValues(alpha: 0.38)
              : colorScheme.onTertiaryContainer,
          splashColor: colorScheme.onTertiaryContainer.withValues(alpha: 0.12),
          highlightColor:
              colorScheme.onTertiaryContainer.withValues(alpha: 0.08),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: colorScheme.tertiaryContainer,
          border: null,
        );
      case AppButtonVariant.outlined:
        return _VariantConfig(
          backgroundColor: isDisabled
              ? colorScheme.onSurface.withValues(alpha: 0.12)
              : Colors.transparent,
          foregroundColor: isDisabled
              ? colorScheme.onSurface.withValues(alpha: 0.38)
              : colorScheme.primary,
          splashColor: colorScheme.primary.withValues(alpha: 0.12),
          highlightColor: colorScheme.primary.withValues(alpha: 0.08),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          border: isDisabled
              ? colorScheme.onSurface.withValues(alpha: 0.12)
              : colorScheme.outline,
        );
      case AppButtonVariant.text:
        return _VariantConfig(
          backgroundColor: Colors.transparent,
          foregroundColor: isDisabled
              ? colorScheme.onSurface.withValues(alpha: 0.38)
              : colorScheme.primary,
          splashColor: colorScheme.primary.withValues(alpha: 0.12),
          highlightColor: colorScheme.primary.withValues(alpha: 0.08),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          border: null,
        );
      case AppButtonVariant.danger:
        return _VariantConfig(
          backgroundColor: isDisabled
              ? colorScheme.onSurface.withValues(alpha: 0.12)
              : colorScheme.error,
          foregroundColor: isDisabled
              ? colorScheme.onSurface.withValues(alpha: 0.38)
              : colorScheme.onError,
          splashColor: colorScheme.onError.withValues(alpha: 0.12),
          highlightColor: colorScheme.onError.withValues(alpha: 0.08),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: colorScheme.error,
          border: null,
        );
    }
  }
}

class _SizeConfig {
  const _SizeConfig({
    required this.textStyle,
    required this.padding,
    required this.iconSize,
    required this.loadingSize,
    required this.loadingStrokeWidth,
    required this.spacing,
  });

  final TextStyle? textStyle;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final double loadingSize;
  final double loadingStrokeWidth;
  final double spacing;
}

class _VariantConfig {
  const _VariantConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.splashColor,
    required this.highlightColor,
    required this.elevation,
    required this.shadowColor,
    required this.surfaceTintColor,
    required this.border,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color splashColor;
  final Color highlightColor;
  final double elevation;
  final Color shadowColor;
  final Color surfaceTintColor;
  final Color? border;
}

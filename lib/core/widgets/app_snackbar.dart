import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum SnackBarType { success, error, info, warning }

/// Utility class to show consistently styled SnackBars.
class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final config = _SnackBarConfig.fromType(type);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(config.icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: config.color,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: actionLabel != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onAction ?? () {},
                )
              : null,
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, type: SnackBarType.success);

  static void error(BuildContext context, String message) =>
      show(context, message, type: SnackBarType.error);

  static void info(BuildContext context, String message) =>
      show(context, message, type: SnackBarType.info);

  static void warning(BuildContext context, String message) =>
      show(context, message, type: SnackBarType.warning);
}

class _SnackBarConfig {
  final Color color;
  final IconData icon;

  const _SnackBarConfig({required this.color, required this.icon});

  factory _SnackBarConfig.fromType(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const _SnackBarConfig(
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case SnackBarType.error:
        return const _SnackBarConfig(
          color: AppColors.error,
          icon: Icons.error_rounded,
        );
      case SnackBarType.warning:
        return const _SnackBarConfig(
          color: AppColors.warning,
          icon: Icons.warning_rounded,
        );
      case SnackBarType.info:
        return const _SnackBarConfig(
          color: AppColors.primary,
          icon: Icons.info_rounded,
        );
    }
  }
}

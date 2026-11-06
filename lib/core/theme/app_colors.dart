import 'package:flutter/material.dart';

/// Central color palette for the School Admission App.
/// All colors are defined here and referenced via AppTheme.
class AppColors {
  AppColors._();

  // ── Primary — Deep Indigo ─────────────────────────────────────────────────
  static const Color primary = Color(0xFF3D5AFE);
  static const Color primaryLight = Color(0xFF8187FF);
  static const Color primaryDark = Color(0xFF0031CA);
  static const Color primaryContainer = Color(0xFFE8ECFF);

  // ── Secondary — Teal ─────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF00BFA5);
  static const Color secondaryLight = Color(0xFF5DF2D6);
  static const Color secondaryDark = Color(0xFF008E76);
  static const Color secondaryContainer = Color(0xFFE0F7F4);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF0F4FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F7FF);

  // ── Status Colors ─────────────────────────────────────────────────────────
  static const Color error = Color(0xFFEF5350);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color success = Color(0xFF00BFA5);
  static const Color successContainer = Color(0xFFE0F7F4);
  static const Color warning = Color(0xFFFF8F00);
  static const Color warningContainer = Color(0xFFFFF3E0);

  // ── Application Status Colors ─────────────────────────────────────────────
  static const Color statusCreated = Color(0xFF3D5AFE);     // indigo
  static const Color statusSlotBooked = Color(0xFF7C4DFF);   // deep purple
  static const Color statusExamCompleted = Color(0xFFFF8F00); // amber
  static const Color statusAdmitted = Color(0xFF00BFA5);     // teal/green

  // ── Text Colors ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ── Border / Divider ─────────────────────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  // ── Gradient Definitions ──────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3D5AFE), Color(0xFF7C4DFF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF3D5AFE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF3D5AFE), Color(0xFF5B6EFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

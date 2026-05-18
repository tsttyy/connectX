import 'package:flutter/material.dart';

class AppColors {
  // Common Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color accent = Color(0xFF06B6D4); // Cyan
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A); // Obsidian Slate
  static const Color darkSurface = Color(0xFF1E293B); // Darker Grey/Indigo
  static const Color darkSurfaceCard = Color(0xFF334155); // Elevated slate card
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Very Light White
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Cool Slate Grey
  static const Color darkBorder = Color(0xFF334155); // Subtle Border
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC); // Clean Slate White
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White
  static const Color lightSurfaceCard = Color(0xFFF1F5F9); // Light Grey/Slate
  static const Color lightTextPrimary = Color(0xFF0F172A); // Deep Charcoal
  static const Color lightTextSecondary = Color(0xFF64748B); // Slate Grey
  static const Color lightBorder = Color(0xFFE2E8F0); // Light Grey Border

  // Status Colors
  static const Color online = Color(0xFF10B981); // Emerald Green
  static const Color offline = Color(0xFF64748B); // Slate Grey
  static const Color error = Color(0xFFEF4444); // Crimson Red
  static const Color success = Color(0xFF10B981); // Emerald Green

  // Premium Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Indigo to Purple
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF43F5E)], // Pink to Rose
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkGlassGradient = LinearGradient(
    colors: [
      Color(0x1AFFFFFF), // 10% white
      Color(0x0DFFFFFF), // 5% white
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

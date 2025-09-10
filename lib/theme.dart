// lib/theme.dart
import 'package:flutter/material.dart';

Color successColor(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  return cs.brightness == Brightness.dark ? const Color(0xFF1DB954) : const Color(0xFF16A34A);
}

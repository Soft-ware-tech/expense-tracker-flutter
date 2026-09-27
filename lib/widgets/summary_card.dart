import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'glass_container.dart';

class SummaryCard extends StatelessWidget {
  final double total;
  final String? label;

  const SummaryCard({super.key, required this.total, this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monthName = DateFormat('MMMM yyyy').format(DateTime.now());
    final formattedAmount = NumberFormat('#,##0.00').format(total);
    final amountColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF0E9F6E);
    final mutedColor = isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.55);
    final faintColor = isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.45);

    return SizedBox(
      height: 108,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -16,
            left: -10,
            child: _glowOrb(const Color(0xFF34D399), 80),
          ),
          Positioned(
            bottom: -20,
            right: -6,
            child: _glowOrb(const Color(0xFF16A34A), 90),
          ),
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  monthName,
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs. ',
                      style: TextStyle(
                        color: amountColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formattedAmount,
                      style: TextStyle(
                        color: amountColor,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  label ?? 'Total spent this month',
                  style: TextStyle(color: faintColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowOrb(Color color, double size) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withOpacity(0.5), color.withOpacity(0.0)],
            ),
          ),
        ),
      ),
    );
  }
}
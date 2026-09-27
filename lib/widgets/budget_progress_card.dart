import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import 'glass_container.dart';

/// Shows the current month's spend against the user's monthly budget, with
/// a progress bar that shifts green -> orange -> red as they get closer to
/// (or go over) their limit. If no budget is set yet, shows a small prompt
/// to set one instead.
class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({super.key});

  Color _progressColor(double progress) {
    if (progress >= 1.0) return const Color(0xFFF87171); // red
    if (progress >= 0.8) return const Color(0xFFF5C563); // orange/amber
    return const Color(0xFF34D399); // green
  }

  Future<void> _showBudgetDialog(BuildContext context, ExpenseProvider provider) async {
    final controller = TextEditingController(
      text: provider.monthlyBudget != null ? provider.monthlyBudget!.toStringAsFixed(0) : '',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF12181F) : Colors.white,
        title: Text('Monthly budget', style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            prefixText: 'Rs. ',
            prefixStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            hintText: 'e.g. 20000',
            hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
          ),
        ),
        actions: [
          if (provider.monthlyBudget != null)
            TextButton(
              onPressed: () {
                provider.clearMonthlyBudget();
                Navigator.pop(ctx);
              },
              child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value != null && value > 0) {
                provider.setMonthlyBudget(value);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: Color(0xFF34D399))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF12181F);
    final mutedColor = isDark ? Colors.white60 : Colors.black54;

    final budget = provider.monthlyBudget;

    if (budget == null) {
      return GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.savings_outlined, color: mutedColor, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Set a monthly budget to track your spending limit',
                style: TextStyle(color: mutedColor, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: () => _showBudgetDialog(context, provider),
              child: const Text('Set budget', style: TextStyle(color: Color(0xFF34D399))),
            ),
          ],
        ),
      );
    }

    final progress = (provider.budgetProgress ?? 0).clamp(0.0, 1.5);
    final color = _progressColor(progress);
    final remaining = provider.budgetRemaining ?? 0;
    final isOverBudget = remaining < 0;

    return GestureDetector(
      onTap: () => _showBudgetDialog(context, provider),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isOverBudget ? Icons.warning_amber_rounded : Icons.savings_outlined,
                  color: color,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Budget: Rs. ${NumberFormat('#,##0').format(budget)} / month',
                    style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.edit, color: mutedColor, size: 12),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        height: 6,
                        width: constraints.maxWidth,
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                      ),
                      Container(
                        height: 6,
                        width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                        color: color,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 5),
            Text(
              isOverBudget
                  ? 'Over budget by Rs. ${NumberFormat('#,##0').format(-remaining)}'
                  : 'Rs. ${NumberFormat('#,##0').format(remaining)} left this month',
              style: TextStyle(
                color: isOverBudget ? const Color(0xFFF87171) : mutedColor,
                fontSize: 11,
                fontWeight: isOverBudget ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
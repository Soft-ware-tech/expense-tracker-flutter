import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/categories.dart';
import '../widgets/glass_container.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final totals = provider.categoryTotalsThisMonth;
    final grandTotal = totals.values.fold(0.0, (sum, v) => sum + v);
    final monthName = DateFormat('MMMM yyyy').format(DateTime.now());

    // Sort categories by amount, highest first
    final sortedEntries = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.8, -0.6),
            radius: 1.4,
            colors: [Color(0xFF14261E), Color(0xFF0B0F14)],
            stops: [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Monthly Summary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: sortedEntries.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.insert_chart_outlined,
                                  color: Colors.white.withOpacity(0.2), size: 56),
                              const SizedBox(height: 16),
                              const Text(
                                'No data for this month yet',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Add some expenses to see your summary',
                                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                        children: [
                          // Simple plain-language summary paragraph
                          GlassContainer(
                            child: _buildInsightParagraph(
                                monthName, grandTotal, sortedEntries),
                          ),
                          const SizedBox(height: 24),
                          GlassContainer(
                            child: SizedBox(
                              height: 200,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: PieChart(
                                      PieChartData(
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 36,
                                        sections: sortedEntries.map((entry) {
                                          final category = getCategoryByName(entry.key);
                                          final percent = grandTotal == 0
                                              ? 0.0
                                              : (entry.value / grandTotal) * 100;
                                          return PieChartSectionData(
                                            value: entry.value,
                                            color: category.color,
                                            radius: 46,
                                            title: '${percent.round()}%',
                                            titleStyle: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: sortedEntries.take(5).map((entry) {
                                        final category = getCategoryByName(entry.key);
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: category.color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  category.name,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Where your money went',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          GlassContainer(
                            child: Column(
                              children: sortedEntries.map((entry) {
                                final category = getCategoryByName(entry.key);
                                final percent =
                                    grandTotal == 0 ? 0.0 : entry.value / grandTotal;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(category.icon, color: category.color, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              category.name,
                                              style: const TextStyle(
                                                  color: Colors.white, fontSize: 13),
                                            ),
                                          ),
                                          Text(
                                            'Rs. ${NumberFormat('#,##0').format(entry.value)}',
                                            style: TextStyle(
                                              color: category.color,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          return Stack(
                                            children: [
                                              Container(
                                                height: 8,
                                                width: constraints.maxWidth,
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.06),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                              Container(
                                                height: 8,
                                                width: constraints.maxWidth * percent,
                                                decoration: BoxDecoration(
                                                  color: category.color,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightParagraph(
      String monthName, double grandTotal, List<MapEntry<String, double>> sorted) {
    if (sorted.isEmpty) {
      return const Text(
        'No expenses recorded yet.',
        style: TextStyle(color: Colors.white70, fontSize: 14),
      );
    }

    final top = sorted.first;
    final topPercent = grandTotal == 0 ? 0 : ((top.value / grandTotal) * 100).round();
    final formattedTotal = NumberFormat('#,##0.00').format(grandTotal);
    final formattedTop = NumberFormat('#,##0.00').format(top.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          monthName,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
            children: [
              const TextSpan(text: 'You spent a total of '),
              TextSpan(
                text: 'Rs. $formattedTotal',
                style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' this month. Your biggest spending category was '),
              TextSpan(
                text: top.key,
                style: TextStyle(color: getCategoryByName(top.key).color, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: ', at Rs. $formattedTop ($topPercent% of your total spending). '
                    'Keeping an eye on this category could be the easiest way to save more next month.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';

/// Shows only the expenses that belong to [monthLabel] (e.g. "September 2026").
/// Reads live from ExpenseProvider so edits/deletes made here update instantly.
class MonthExpensesScreen extends StatelessWidget {
  final String monthLabel;

  const MonthExpensesScreen({super.key, required this.monthLabel});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    final monthExpenses = provider.filteredExpenses
        .where((e) => DateFormat('MMMM yyyy').format(e.date) == monthLabel)
        .toList();

    final total = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);

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
                padding: const EdgeInsets.fromLTRB(8, 12, 20, 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            monthLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rs. ${NumberFormat('#,##0.00').format(total)} total',
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: monthExpenses.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.receipt_long, color: Colors.white.withOpacity(0.2), size: 56),
                              const SizedBox(height: 16),
                              Text(
                                'No expenses in $monthLabel',
                                style: const TextStyle(color: Colors.white, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: monthExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = monthExpenses[index];
                          return ExpenseCard(
                            expense: expense,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddExpenseScreen(existingExpense: expense),
                                ),
                              );
                            },
                            onDelete: () => provider.deleteExpense(expense.id!),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
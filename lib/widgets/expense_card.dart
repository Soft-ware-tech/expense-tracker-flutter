import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../utils/categories.dart';
import 'glass_container.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF12181F),
            title: const Text('Delete expense?', style: TextStyle(color: Colors.white)),
            content: Text(
              'Are you sure you want to delete "${expense.title}"?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final category = getCategoryByName(expense.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(expense.id ?? UniqueKey().toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) => _confirmDelete(context),
        onDismissed: (_) => onDelete(),
        child: GestureDetector(
          onTap: onTap,
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: category.color.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(category.icon, color: category.color, size: 22),
                    ),
                    if (expense.receiptUrl != null)
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFF12181F),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.attach_file, size: 11, color: Color(0xFF34D399)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${expense.category} · ${DateFormat('dd MMM yyyy').format(expense.date)}',
                        style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Rs. ${NumberFormat('#,##0.00').format(expense.amount)}',
                  style: const TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Explicit delete button - swipe-to-delete above works great on
                // touch devices, but is awkward with a mouse on web/desktop, so
                // this gives every platform a reliable way to delete.
                IconButton(
                  onPressed: () async {
                    final confirmed = await _confirmDelete(context);
                    if (confirmed) onDelete();
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
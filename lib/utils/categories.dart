import 'package:flutter/material.dart';

class ExpenseCategory {
  final String name;
  final IconData icon;
  final Color color;

  const ExpenseCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

const List<ExpenseCategory> kCategories = [
  ExpenseCategory(name: 'Food', icon: Icons.restaurant, color: Color(0xFFF5C563)),
  ExpenseCategory(name: 'Transport', icon: Icons.directions_bus, color: Color(0xFF60A5FA)),
  ExpenseCategory(name: 'Shopping', icon: Icons.shopping_bag, color: Color(0xFFEC7FA9)),
  ExpenseCategory(name: 'Bills', icon: Icons.receipt_long, color: Color(0xFFF87171)),
  ExpenseCategory(name: 'Entertainment', icon: Icons.movie, color: Color(0xFFA78BFA)),
  ExpenseCategory(name: 'Health', icon: Icons.favorite, color: Color(0xFF34D399)),
  ExpenseCategory(name: 'Education', icon: Icons.school, color: Color(0xFF38BDF8)),
  ExpenseCategory(name: 'Other', icon: Icons.category, color: Color(0xFF9CA3AF)),
];

ExpenseCategory getCategoryByName(String name) {
  return kCategories.firstWhere(
    (c) => c.name == name,
    orElse: () => kCategories.last,
  );
}
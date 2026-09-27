import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  final String? receiptUrl;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.receiptUrl,
  });

  // Convert Expense object -> Map, for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'note': note ?? '',
      'receiptUrl': receiptUrl,
    };
  }

  // Convert Firestore document -> Expense object
  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    return Expense(
      id: id,
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? 'Other',
      date: (map['date'] as Timestamp).toDate(),
      note: map['note'],
      receiptUrl: map['receiptUrl'],
    );
  }

  // Helper to create a copy with updated fields (useful for editing)
  Expense copyWith({
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    String? receiptUrl,
    bool clearReceipt = false,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      receiptUrl: clearReceipt ? null : (receiptUrl ?? this.receiptUrl),
    );
  }
}

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/expense_model.dart';

/// Builds a CSV file from [expenses] and opens the system share sheet so the
/// user can save it to Files/Drive, email it, etc. Returns false (and shows
/// no share sheet) if there is nothing to export.
Future<bool> exportExpensesToCsv(
  List<Expense> expenses, {
  String fileLabel = 'expenses',
}) async {
  if (expenses.isEmpty) return false;

  final rows = <List<dynamic>>[
    ['Title', 'Amount', 'Category', 'Date', 'Note'],
    ...expenses.map((e) => [
          e.title,
          e.amount.toStringAsFixed(2),
          e.category,
          DateFormat('yyyy-MM-dd').format(e.date),
          e.note ?? '',
        ]),
  ];

  final csvData = const ListToCsvConverter().convert(rows);

  final dir = await getTemporaryDirectory();
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final file = File('${dir.path}/${fileLabel}_$timestamp.csv');
  await file.writeAsString(csvData);

  await Share.shareXFiles(
    [XFile(file.path)],
    subject: 'Expense export ($fileLabel)',
    text: 'Exported ${expenses.length} expense(s) from Expense Tracker.',
  );
  return true;
}

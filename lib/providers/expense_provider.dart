import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';
import '../services/budget_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  final BudgetService _budgetService = BudgetService();
  StreamSubscription? _subscription;
  StreamSubscription? _authSubscription;
  StreamSubscription? _budgetSubscription;

  List<Expense> _allExpenses = [];
  bool isLoading = true;
  String? errorMessage;

  String? selectedCategory;
  DateTime? selectedDate;
  String searchQuery = '';

  /// The signed-in user's monthly budget limit, or null if none is set yet.
  double? monthlyBudget;

  ExpenseProvider() {
    // Re-subscribe to the Firestore stream whenever the signed-in user
    // changes (login/logout), so each user only ever sees their own data.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      _listenToExpenses();
      _listenToBudget();
    });
  }

  void _listenToBudget() {
    _budgetSubscription?.cancel();
    _budgetSubscription = _budgetService.getBudgetStream().listen((limit) {
      monthlyBudget = limit;
      notifyListeners();
    });
  }

  Future<void> setMonthlyBudget(double limit) => _budgetService.setMonthlyBudget(limit);

  Future<void> clearMonthlyBudget() => _budgetService.clearBudget();

  /// 0.0 - 1.0+ how much of the budget has been used this month.
  /// Returns null when no budget has been set.
  double? get budgetProgress {
    if (monthlyBudget == null || monthlyBudget == 0) return null;
    return currentMonthTotal / monthlyBudget!;
  }

  double? get budgetRemaining {
    if (monthlyBudget == null) return null;
    return monthlyBudget! - currentMonthTotal;
  }

  void _listenToExpenses() {
    isLoading = true;
    _allExpenses = [];
    notifyListeners();

    _subscription?.cancel();
    _subscription = _service.getExpensesStream().listen(
      (expenses) {
        _allExpenses = expenses;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('FIRESTORE ERROR: $error');
        errorMessage =
            'Something went wrong while loading expenses. Please check your connection.';
        isLoading = false;
        notifyListeners();
      },
    );
  }

  List<Expense> get allExpenses => _allExpenses;

  List<Expense> get filteredExpenses {
    return _allExpenses.where((e) {
      final categoryMatch =
          selectedCategory == null || e.category == selectedCategory;
      final dateMatch = selectedDate == null ||
          (e.date.year == selectedDate!.year &&
              e.date.month == selectedDate!.month &&
              e.date.day == selectedDate!.day);
      final searchMatch = searchQuery.isEmpty ||
          e.title.toLowerCase().contains(searchQuery.toLowerCase());
      return categoryMatch && dateMatch && searchMatch;
    }).toList();
  }

  double get currentMonthTotal {
    final now = DateTime.now();
    return _allExpenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> get categoryTotalsThisMonth {
    final now = DateTime.now();
    final Map<String, double> totals = {};
    for (var e in _allExpenses) {
      if (e.date.year == now.year && e.date.month == now.month) {
        totals[e.category] = (totals[e.category] ?? 0) + e.amount;
      }
    }
    return totals;
  }

  void setCategoryFilter(String? category) {
    selectedCategory = category;
    notifyListeners();
  }

  void setDateFilter(DateTime? date) {
    selectedDate = date;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    selectedCategory = null;
    selectedDate = null;
    searchQuery = '';
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) => _service.addExpense(expense);
  Future<void> updateExpense(Expense expense) => _service.updateExpense(expense);
  Future<void> deleteExpense(String id) => _service.deleteExpense(id);

  @override
  void dispose() {
    _subscription?.cancel();
    _authSubscription?.cancel();
    _budgetSubscription?.cancel();
    super.dispose();
  }
}
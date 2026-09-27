import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense_model.dart';

class FirestoreService {
  final CollectionReference _expensesRef =
      FirebaseFirestore.instance.collection('expenses');

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Only streams the expenses that belong to the currently signed-in user.
  /// Ordering is done client-side (instead of an orderBy + where query) so we
  /// don't force the user to create a composite Firestore index.
  Stream<List<Expense>> getExpensesStream() {
    final uid = _uid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _expensesRef.where('userId', isEqualTo: uid).snapshots().map(
          (snapshot) {
        final expenses = snapshot.docs
            .map((doc) =>
                Expense.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
        expenses.sort((a, b) => b.date.compareTo(a.date));
        return expenses;
      },
    );
  }

  Future<void> addExpense(Expense expense) async {
    final uid = _uid;
    if (uid == null) throw Exception('You must be signed in to add an expense.');
    final data = expense.toMap()..['userId'] = uid;
    await _expensesRef.add(data);
  }

  Future<void> updateExpense(Expense expense) async {
    final uid = _uid;
    if (uid == null) throw Exception('You must be signed in to update an expense.');
    final data = expense.toMap()..['userId'] = uid;
    await _expensesRef.doc(expense.id).update(data);
  }

  Future<void> deleteExpense(String id) async {
    await _expensesRef.doc(id).delete();
  }
}
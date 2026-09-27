import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Stores each signed-in user's monthly budget limit at budgets/{uid}.
/// Kept in its own document (rather than inside the expenses collection)
/// so it's cheap to read/watch independently of the expense list.
class BudgetService {
  final CollectionReference _budgetsRef =
      FirebaseFirestore.instance.collection('budgets');

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Streams the current user's monthly budget limit (null if not set yet
  /// or if no user is signed in).
  Stream<double?> getBudgetStream() {
    final uid = _uid;
    if (uid == null) return Stream.value(null);
    return _budgetsRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>?;
      final limit = data?['monthlyLimit'];
      if (limit == null) return null;
      return (limit as num).toDouble();
    });
  }

  Future<void> setMonthlyBudget(double limit) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('You must be signed in to set a budget.');
    }
    await _budgetsRef.doc(uid).set({
      'userId': uid,
      'monthlyLimit': limit,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> clearBudget() async {
    final uid = _uid;
    if (uid == null) return;
    await _budgetsRef.doc(uid).delete();
  }
}

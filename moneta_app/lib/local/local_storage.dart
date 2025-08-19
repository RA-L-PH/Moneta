import 'package:hive_flutter/hive_flutter.dart';
import 'local_models.dart';

class LocalStorage {
  static const boxName = 'local_txns';
  static const reportsBoxName = 'monthly_reports';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LocalTxnAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MonthlyReportAdapter());
    }
    await Hive.openBox<LocalTxn>(boxName);
    await Hive.openBox<MonthlyReport>(reportsBoxName);
  }

  static Box<LocalTxn> get _box => Hive.box<LocalTxn>(boxName);
  static Box<MonthlyReport> get _reportsBox =>
      Hive.box<MonthlyReport>(reportsBoxName);

  static Future<void> upsert(LocalTxn t) async {
    // Check for duplicates before adding
    if (!_isDuplicate(t)) {
      await _box.add(t);
    }
  }

  /// Check if a transaction is a duplicate based on content similarity
  static bool _isDuplicate(LocalTxn newTxn) {
    final existing = _box.values.toList().cast<LocalTxn>();

    for (final existingTxn in existing) {
      // Check if transactions are similar enough to be considered duplicates
      if (_areTransactionsSimilar(newTxn, existingTxn)) {
        return true;
      }
    }
    return false;
  }

  /// Compare two transactions to determine if they are duplicates
  static bool _areTransactionsSimilar(LocalTxn txn1, LocalTxn txn2) {
    // Same amount, type, and similar date (within 1 minute)
    if (txn1.amount == txn2.amount &&
        txn1.type == txn2.type &&
        txn1.date.difference(txn2.date).abs().inMinutes <= 1) {
      // Check if party names are similar (accounting for case and whitespace)
      final party1 = txn1.party.trim().toLowerCase();
      final party2 = txn2.party.trim().toLowerCase();

      if (party1 == party2) {
        return true;
      }

      // Check if one party name contains the other (for variations)
      if (party1.isNotEmpty &&
          party2.isNotEmpty &&
          (party1.contains(party2) || party2.contains(party1))) {
        return true;
      }

      // Check if raw SMS content is identical
      if (txn1.raw.trim() == txn2.raw.trim()) {
        return true;
      }
    }

    return false;
  }

  static List<LocalTxn> all() => _box.values.toList().cast<LocalTxn>();

  static Future<void> clear() => _box.clear();

  // Monthly reports methods
  static Future<void> saveMonthlyReport(MonthlyReport report) async {
    final key = '${report.year}-${report.month.toString().padLeft(2, '0')}';
    await _reportsBox.put(key, report);
  }

  static MonthlyReport? getMonthlyReport(int year, int month) {
    final key = '${year}-${month.toString().padLeft(2, '0')}';
    return _reportsBox.get(key);
  }

  static List<MonthlyReport> getAllReports() {
    return _reportsBox.values.toList().cast<MonthlyReport>()..sort((a, b) {
      final aDate = DateTime(a.year, a.month);
      final bDate = DateTime(b.year, b.month);
      return bDate.compareTo(aDate); // Most recent first
    });
  }

  static List<String> getAllCategories() {
    final categories = <String>{};
    for (final txn in all()) {
      if (txn.type == 'debit' && txn.category.isNotEmpty) {
        categories.add(txn.category);
      }
    }
    categories.addAll([
      'Food',
      'Transport',
      'Entertainment',
      'Shopping',
      'Bills',
      'Healthcare',
      'Other',
    ]);
    return categories.toList()..sort();
  }
}

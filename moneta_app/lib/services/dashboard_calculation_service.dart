import '../local/local_storage.dart';
import '../local/local_models.dart';

/// Service to handle dashboard calculations with duplicate filtering
class DashboardCalculationService {
  /// Calculate current month's debited, credited, and balance after filtering duplicates
  static Map<String, double> getCurrentMonthCalculations() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(
      now.year,
      now.month + 1,
      0,
    ); // Last day of current month

    // Get all transactions
    final allTransactions = LocalStorage.all();

    // Filter current month transactions
    final currentMonthTransactions =
        allTransactions
            .where(
              (t) =>
                  t.date.isAfter(firstDay.subtract(const Duration(days: 1))) &&
                  t.date.isBefore(lastDay.add(const Duration(days: 1))),
            )
            .toList();

    // Apply duplicate filtering
    final uniqueTransactions = _removeDuplicates(currentMonthTransactions);

    // Calculate totals
    double totalDebited = 0;
    double totalCredited = 0;
    double? latestBalance;
    DateTime? latestBalanceDate;

    // Sort by date to get latest balance
    uniqueTransactions.sort((a, b) => b.date.compareTo(a.date));

    for (final transaction in uniqueTransactions) {
      if (transaction.type == 'credit') {
        totalCredited += transaction.amount;
      } else {
        totalDebited += transaction.amount;
      }

      // Track latest balance
      if (transaction.balance != null) {
        if (latestBalanceDate == null ||
            transaction.date.isAfter(latestBalanceDate)) {
          latestBalanceDate = transaction.date;
          latestBalance = transaction.balance;
        }
      }
    }

    // If no balance found in current month, get the latest from all transactions
    if (latestBalance == null) {
      final allTransactionsWithBalance =
          allTransactions.where((t) => t.balance != null).toList()
            ..sort((a, b) => b.date.compareTo(a.date));

      if (allTransactionsWithBalance.isNotEmpty) {
        latestBalance = allTransactionsWithBalance.first.balance;
      }
    }

    return {
      'debited': totalDebited,
      'credited': totalCredited,
      'balance': latestBalance ?? 0.0,
    };
  }

  /// Get spending breakdown by category for current month (after duplicate filtering)
  static Map<String, double> getCurrentMonthCategoryBreakdown() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    final allTransactions = LocalStorage.all();

    // Filter current month transactions
    final currentMonthTransactions =
        allTransactions
            .where(
              (t) =>
                  t.date.isAfter(firstDay.subtract(const Duration(days: 1))) &&
                  t.date.isBefore(lastDay.add(const Duration(days: 1))),
            )
            .toList();

    // Apply duplicate filtering
    final uniqueTransactions = _removeDuplicates(currentMonthTransactions);

    // Calculate category breakdown (only for debit transactions)
    final Map<String, double> categoryBreakdown = {};

    for (final transaction in uniqueTransactions) {
      if (transaction.type == 'debit') {
        final category =
            transaction.category.isEmpty ? 'Other' : transaction.category;
        categoryBreakdown[category] =
            (categoryBreakdown[category] ?? 0) + transaction.amount;
      }
    }

    return categoryBreakdown;
  }

  /// Remove duplicate transactions using the same logic as LocalStorage
  static List<LocalTxn> _removeDuplicates(List<LocalTxn> transactions) {
    final uniqueTransactions = <LocalTxn>[];

    for (final transaction in transactions) {
      bool isDuplicate = false;

      for (final existing in uniqueTransactions) {
        if (_areTransactionsSimilar(transaction, existing)) {
          isDuplicate = true;
          break;
        }
      }

      if (!isDuplicate) {
        uniqueTransactions.add(transaction);
      }
    }

    return uniqueTransactions;
  }

  /// Compare two transactions to determine if they are duplicates
  /// This uses the same logic as LocalStorage._areTransactionsSimilar
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

  /// Get recent transactions for display (after duplicate filtering)
  static List<LocalTxn> getRecentTransactions({int limit = 5}) {
    final allTransactions = LocalStorage.all();
    final uniqueTransactions = _removeDuplicates(allTransactions);

    // Sort by date (most recent first)
    uniqueTransactions.sort((a, b) => b.date.compareTo(a.date));

    return uniqueTransactions.take(limit).toList();
  }

  /// Get transaction count for current month (after duplicate filtering)
  static int getCurrentMonthTransactionCount() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    final allTransactions = LocalStorage.all();

    final currentMonthTransactions =
        allTransactions
            .where(
              (t) =>
                  t.date.isAfter(firstDay.subtract(const Duration(days: 1))) &&
                  t.date.isBefore(lastDay.add(const Duration(days: 1))),
            )
            .toList();

    final uniqueTransactions = _removeDuplicates(currentMonthTransactions);
    return uniqueTransactions.length;
  }
}

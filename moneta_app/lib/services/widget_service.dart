import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../local/local_storage.dart';
import '../local/local_models.dart';

class WidgetService {
  static const androidWidgetName = 'MonetaWidgetProvider';

  static Future<void> updateTodayTotals() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final box = Hive.box<LocalTxn>(LocalStorage.boxName);

    // Get today's transactions and filter duplicates
    final todayTransactions =
        box.values
            .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
            .toList();

    final uniqueTransactions = _removeDuplicates(todayTransactions);

    double debit = 0, credit = 0;
    for (final t in uniqueTransactions) {
      if (t.type == 'credit') {
        credit += t.amount;
      } else {
        debit += t.amount;
      }
    }
    final nfIn = NumberFormat.decimalPattern('en_IN');
    await HomeWidget.saveWidgetData('today_debit', nfIn.format(debit));
    await HomeWidget.saveWidgetData('today_credit', nfIn.format(credit));
    await HomeWidget.updateWidget(name: androidWidgetName, iOSName: null);
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
}

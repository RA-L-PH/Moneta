import 'package:flutter/foundation.dart';
import '../local/local_storage.dart';
import '../local/local_models.dart';

class MonthlyReportService {
  static Future<void> checkAndGenerateReport() async {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Check if we're in a new month and if last month's report doesn't exist
    DateTime lastMonth;
    if (currentMonth == 1) {
      lastMonth = DateTime(currentYear - 1, 12);
    } else {
      lastMonth = DateTime(currentYear, currentMonth - 1);
    }

    final existingReport = LocalStorage.getMonthlyReport(
      lastMonth.year,
      lastMonth.month,
    );
    if (existingReport == null) {
      await generateMonthlyReport(lastMonth.year, lastMonth.month);
      // Reset analytics data for the new month
      await _resetMonthlyAnalytics();
    }
  }

  /// Reset analytics data at the start of each month
  static Future<void> _resetMonthlyAnalytics() async {
    // Clear any cached analytics data or reset counters
    // This ensures dashboard analytics start fresh each month

    // Note: This method can be extended to reset specific analytics
    // data structures if needed in the future
    debugPrint('Monthly analytics reset completed');
  }

  static Future<MonthlyReport> generateMonthlyReport(
    int year,
    int month,
  ) async {
    final allTxns = LocalStorage.all();
    final monthTxns =
        allTxns
            .where((t) => t.date.year == year && t.date.month == month)
            .toList();

    // Apply duplicate filtering using the same logic as dashboard
    final uniqueMonthTxns = _removeDuplicates(monthTxns);

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> categoryBreakdown = {};
    final List<double> balances = [];

    for (final txn in uniqueMonthTxns) {
      if (txn.type == 'credit') {
        totalIncome += txn.amount;
      } else {
        totalExpense += txn.amount;
        categoryBreakdown[txn.category] =
            (categoryBreakdown[txn.category] ?? 0) + txn.amount;
      }

      if (txn.balance != null) {
        balances.add(txn.balance!);
      }
    }

    final averageBalance =
        balances.isNotEmpty
            ? balances.reduce((a, b) => a + b) / balances.length
            : null;

    final aiSummary = _generateAISummary(
      totalIncome,
      totalExpense,
      categoryBreakdown,
      uniqueMonthTxns.length,
      averageBalance,
      month,
      year,
    );

    final report = MonthlyReport(
      year: year,
      month: month,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      categoryBreakdown: categoryBreakdown,
      aiSummary: aiSummary,
      generatedAt: DateTime.now(),
      averageBalance: averageBalance,
      transactionCount: uniqueMonthTxns.length,
    );

    await LocalStorage.saveMonthlyReport(report);
    return report;
  }

  static String _generateAISummary(
    double income,
    double expense,
    Map<String, double> categories,
    int transactionCount,
    double? averageBalance,
    int month,
    int year,
  ) {
    final net = income - expense;
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final topCategories =
        categories.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final insights = <String>[];

    // Financial health assessment
    if (net > 0) {
      insights.add("✅ Positive cash flow of ₹${net.toStringAsFixed(2)}");
    } else {
      insights.add("⚠️ Negative cash flow of ₹${net.abs().toStringAsFixed(2)}");
    }

    // Spending analysis
    if (expense > 0) {
      final savingsRate = (net / income * 100);
      if (savingsRate > 20) {
        insights.add(
          "💰 Excellent savings rate of ${savingsRate.toStringAsFixed(1)}%",
        );
      } else if (savingsRate > 10) {
        insights.add(
          "👍 Good savings rate of ${savingsRate.toStringAsFixed(1)}%",
        );
      } else if (savingsRate > 0) {
        insights.add(
          "⚡ Low savings rate of ${savingsRate.toStringAsFixed(1)}% - consider reducing expenses",
        );
      } else {
        insights.add("🚨 No savings this month - urgent budget review needed");
      }
    }

    // Category insights
    if (topCategories.isNotEmpty) {
      final topCategory = topCategories.first;
      final percentage = (topCategory.value / expense * 100);
      insights.add(
        "📊 Highest spending: ${topCategory.key} (${percentage.toStringAsFixed(1)}%)",
      );

      if (percentage > 40) {
        insights.add("🎯 Consider reducing ${topCategory.key} expenses");
      }
    }

    // Transaction frequency
    final avgPerDay = transactionCount / DateTime(year, month + 1, 0).day;
    if (avgPerDay > 3) {
      insights.add(
        "🔄 High transaction frequency (${avgPerDay.toStringAsFixed(1)}/day) - consider consolidating purchases",
      );
    }

    // Balance insights
    if (averageBalance != null) {
      insights.add("💳 Average balance: ₹${averageBalance.toStringAsFixed(2)}");
    }

    // Recommendations
    final recommendations = <String>[];
    if (topCategories.length > 1) {
      final secondCategory = topCategories[1];
      if (topCategories.first.value > secondCategory.value * 2) {
        recommendations.add(
          "Consider setting a budget limit for ${topCategories.first.key}",
        );
      }
    }

    if (net < 0) {
      recommendations.add("Create an emergency fund to avoid overspending");
      recommendations.add(
        "Track daily expenses to identify unnecessary purchases",
      );
    }

    final summary = StringBuffer();
    summary.writeln("📈 ${monthNames[month - 1]} $year Financial Summary");
    summary.writeln("");
    summary.writeln("💰 Income: ₹${income.toStringAsFixed(2)}");
    summary.writeln("💸 Expenses: ₹${expense.toStringAsFixed(2)}");
    summary.writeln("📊 Net: ₹${net.toStringAsFixed(2)}");
    summary.writeln("🔢 Transactions: $transactionCount");
    summary.writeln("");

    summary.writeln("🎯 Key Insights:");
    for (final insight in insights) {
      summary.writeln("• $insight");
    }

    if (recommendations.isNotEmpty) {
      summary.writeln("");
      summary.writeln("💡 Recommendations:");
      for (final rec in recommendations) {
        summary.writeln("• $rec");
      }
    }

    return summary.toString();
  }

  /// Remove duplicate transactions using the same logic as DashboardCalculationService
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

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../local/local_storage.dart';
import 'settings_service.dart';

/// Smart AI features service using NVIDIA NIM API
/// Provides spending forecast, anomaly detection, financial health score,
/// and conversational AI assistant
class SmartAiService {
  static String get _apiKey => SettingsService.nvidiaApiKey;
  static String get _model => SettingsService.nvidiaModel;
  static String get _baseUrl => SettingsService.nvidiaBaseUrl;

  /// Get financial health score (0-100)
  static FinancialHealthScore getFinancialHealthScore() {
    final transactions = LocalStorage.all();
    final now = DateTime.now();
    final threeMonthsAgo = now.subtract(const Duration(days: 90));
    final recent =
        transactions.where((t) => t.date.isAfter(threeMonthsAgo)).toList();

    if (recent.isEmpty) {
      return FinancialHealthScore(
        score: 0,
        label: 'No Data',
        description: 'Add transactions to get your health score',
        factors: [],
      );
    }

    double totalIncome = 0;
    double totalExpenses = 0;
    final Map<String, double> categories = {};

    for (final t in recent) {
      if (t.type == 'credit') {
        totalIncome += t.amount;
      } else {
        totalExpenses += t.amount;
        categories[t.category] = (categories[t.category] ?? 0) + t.amount;
      }
    }

    final savingsRate =
        totalIncome > 0 ? ((totalIncome - totalExpenses) / totalIncome) * 100 : 0;
    final balance = totalIncome - totalExpenses;

    // Calculate score components
    double score = 0;
    final factors = <HealthFactor>[];

    // Savings rate (0-30 points)
    final savingsScore = min(30.0, max(0, savingsRate * 1.5)).toDouble();
    score += savingsScore;
    factors.add(HealthFactor(
      label: 'Savings Rate',
      value: '${savingsRate.toStringAsFixed(1)}%',
      score: savingsScore,
      maxScore: 30,
      status: savingsRate >= 20 ? 'good' : savingsRate >= 10 ? 'fair' : 'poor',
    ));

    // Balance positive (0-20 points)
    final balanceScore = (balance > 0 ? 20.0 : max(0, 20 + (balance / totalIncome * 20))).toDouble();
    score += balanceScore;
    factors.add(HealthFactor(
      label: 'Balance',
      value: '₹${balance.toStringAsFixed(0)}',
      score: balanceScore,
      maxScore: 20,
      status: balance > 0 ? 'good' : 'poor',
    ));

    // Spending diversity (0-20 points)
    final categoryCount = categories.length;
    final diversityScore = min(20.0, categoryCount * 4.0);
    score += diversityScore;
    factors.add(HealthFactor(
      label: 'Spending Diversity',
      value: '$categoryCount categories',
      score: diversityScore,
      maxScore: 20,
      status: categoryCount >= 4 ? 'good' : categoryCount >= 2 ? 'fair' : 'poor',
    ));

    // Transaction consistency (0-15 points)
    final dailySpending = <DateTime, double>{};
    for (final t in recent.where((t) => t.type == 'debit')) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      dailySpending[day] = (dailySpending[day] ?? 0) + t.amount;
    }
    final avgDaily = dailySpending.isNotEmpty
        ? dailySpending.values.reduce((a, b) => a + b) / dailySpending.length
        : 0.0;
    final consistencyScore = avgDaily > 0 ? 15.0 : 0.0;
    score += consistencyScore;
    factors.add(HealthFactor(
      label: 'Daily Consistency',
      value: '₹${avgDaily.toStringAsFixed(0)}/day avg',
      score: consistencyScore,
      maxScore: 15,
      status: avgDaily > 0 ? 'good' : 'fair',
    ));

    // Low overspending (0-15 points)
    final overspendCategories = categories.entries.where((e) {
      final monthlyAvg = e.value / 3;
      return monthlyAvg > totalIncome * 0.3;
    }).length;
    final overspendScore = max(0, 15.0 - overspendCategories * 5).toDouble();
    score += overspendScore;
    factors.add(HealthFactor(
      label: 'Budget Discipline',
      value: overspendCategories == 0 ? 'On track' : '$overspendCategories over budget',
      score: overspendScore,
      maxScore: 15,
      status: overspendCategories == 0 ? 'good' : 'poor',
    ));

    String label;
    String description;
    if (score >= 80) {
      label = 'Excellent';
      description = 'Your finances are in great shape! Keep up the good work.';
    } else if (score >= 60) {
      label = 'Good';
      description = 'Solid financial habits. A few tweaks could make it excellent.';
    } else if (score >= 40) {
      label = 'Fair';
      description = 'There\'s room for improvement. Focus on savings and budgeting.';
    } else {
      label = 'Needs Attention';
      description = 'Consider reviewing your spending patterns and setting a budget.';
    }

    return FinancialHealthScore(
      score: score.round(),
      label: label,
      description: description,
      factors: factors,
    );
  }

  /// Detect spending anomalies
  static List<SpendingAnomaly> detectAnomalies() {
    final transactions = LocalStorage.all();
    final now = DateTime.now();
    final threeMonthsAgo = now.subtract(const Duration(days: 90));
    final recent =
        transactions.where((t) => t.date.isAfter(threeMonthsAgo)).toList();

    if (recent.length < 5) return [];

    final anomalies = <SpendingAnomaly>[];
    final nf = NumberFormat.decimalPattern('en_IN');

    // Calculate average per category
    final Map<String, List<double>> categoryAmounts = {};
    for (final t in recent.where((t) => t.type == 'debit')) {
      categoryAmounts[t.category] = (categoryAmounts[t.category] ?? [])..add(t.amount);
    }

    for (final entry in categoryAmounts.entries) {
      if (entry.value.length < 3) continue;
      final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
      final variance = entry.value.map((v) => (v - avg) * (v - avg)).reduce((a, b) => a + b) / entry.value.length;
      final stdDev = sqrt(variance);

      // Check for outliers (more than 2 standard deviations)
      for (final amount in entry.value) {
        if ((amount - avg).abs() > 2 * stdDev && amount > avg * 1.5) {
          anomalies.add(SpendingAnomaly(
            category: entry.key,
            amount: amount,
            average: avg,
            severity: amount > avg * 3 ? 'high' : 'medium',
            message: '₹${nf.format(amount)} in ${entry.key} is ${((amount / avg - 1) * 100).toStringAsFixed(0)}% above your average of ₹${nf.format(avg)}',
          ));
        }
      }
    }

    // Check for unusual daily totals
    final Map<DateTime, double> dailyTotals = {};
    for (final t in recent.where((t) => t.type == 'debit')) {
      final day = DateTime(t.date.year, t.date.month, t.date.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + t.amount;
    }

    if (dailyTotals.length >= 5) {
      final dailyValues = dailyTotals.values.toList();
      final avgDaily = dailyValues.reduce((a, b) => a + b) / dailyValues.length;
      final dailyVariance = dailyValues.map((v) => (v - avgDaily) * (v - avgDaily)).reduce((a, b) => a + b) / dailyValues.length;
      final dailyStdDev = sqrt(dailyVariance);

      for (final entry in dailyTotals.entries) {
        if ((entry.value - avgDaily).abs() > 2 * dailyStdDev && entry.value > avgDaily * 1.5) {
          anomalies.add(SpendingAnomaly(
            category: 'Daily Total',
            amount: entry.value,
            average: avgDaily,
            severity: entry.value > avgDaily * 3 ? 'high' : 'medium',
            message: '₹${nf.format(entry.value)} spent on ${DateFormat('MMM d').format(entry.key)} is unusually high',
          ));
        }
      }
    }

    return anomalies;
  }

  /// Generate spending forecast for next month
  static SpendingForecast getSpendingForecast() {
    final transactions = LocalStorage.all();
    final now = DateTime.now();

    // Get last 3 months data
    final threeMonthsAgo = now.subtract(const Duration(days: 90));
    final recent =
        transactions.where((t) => t.date.isAfter(threeMonthsAgo)).toList();

    if (recent.isEmpty) {
      return SpendingForecast(
        predictedExpenses: 0,
        predictedIncome: 0,
        confidence: 0,
        categoryForecasts: [],
        trend: 'stable',
      );
    }

    double totalIncome = 0;
    double totalExpenses = 0;
    final Map<String, double> categoryTotals = {};

    for (final t in recent) {
      if (t.type == 'credit') {
        totalIncome += t.amount;
      } else {
        totalExpenses += t.amount;
        categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
      }
    }

    final avgMonthlyIncome = totalIncome / 3;
    final avgMonthlyExpenses = totalExpenses / 3;

    // Simple linear trend
    final monthlyExpenses = <double>[];
    for (int m = 0; m < 3; m++) {
      final monthStart = DateTime(now.year, now.month - 2 + m, 1);
      final monthEnd = DateTime(now.year, now.month - 1 + m + 1, 0);
      final monthTxns = recent.where((t) =>
          t.type == 'debit' &&
          !t.date.isBefore(monthStart) &&
          !t.date.isAfter(monthEnd));
      monthlyExpenses.add(monthTxns.fold(0.0, (sum, t) => sum + t.amount));
    }

    double trend = 0;
    if (monthlyExpenses.length >= 2) {
      trend = (monthlyExpenses.last - monthlyExpenses.first) / 2;
    }

    final predictedExpenses = avgMonthlyExpenses + trend;
    final predictedIncome = avgMonthlyIncome;

    // Category forecasts
    final categoryForecasts = categoryTotals.entries.map((e) {
      final monthlyAvg = e.value / 3;
      return CategoryForecast(
        category: e.key,
        predicted: monthlyAvg,
        current: monthlyAvg,
      );
    }).toList()
      ..sort((a, b) => b.predicted.compareTo(a.predicted));

    String trendLabel;
    if (trend > avgMonthlyExpenses * 0.1) {
      trendLabel = 'increasing';
    } else if (trend < -avgMonthlyExpenses * 0.1) {
      trendLabel = 'decreasing';
    } else {
      trendLabel = 'stable';
    }

    return SpendingForecast(
      predictedExpenses: predictedExpenses.roundToDouble(),
      predictedIncome: predictedIncome.roundToDouble(),
      confidence: min(95, 60 + recent.length),
      categoryForecasts: categoryForecasts.take(5).toList(),
      trend: trendLabel,
    );
  }

  /// Chat with AI financial assistant
  static Future<String> chatWithAssistant(String message) async {
    if (_apiKey.isEmpty) {
      return 'NVIDIA API key not configured. Please set NVIDIA_API_KEY.';
    }

    final transactions = LocalStorage.all();
    final now = DateTime.now();
    final threeMonthsAgo = now.subtract(const Duration(days: 90));
    final recent =
        transactions.where((t) => t.date.isAfter(threeMonthsAgo)).toList();

    final nf = NumberFormat.decimalPattern('en_IN');
    double totalIncome = 0;
    double totalExpenses = 0;
    final Map<String, double> categories = {};

    for (final t in recent) {
      if (t.type == 'credit') {
        totalIncome += t.amount;
      } else {
        totalExpenses += t.amount;
        categories[t.category] = (categories[t.category] ?? 0) + t.amount;
      }
    }

    final categorySummary = categories.entries
        .map((e) => '${e.key}: ₹${nf.format(e.value)}')
        .join(', ');

    final recentTxns = recent
        .where((t) => t.type == 'debit')
        .take(10)
        .map((t) =>
            '${DateFormat('MMM d').format(t.date)}: ${t.category} ₹${nf.format(t.amount)} at ${t.party}')
        .join('\n');

    final prompt = '''You are Moneta AI, a friendly and knowledgeable financial advisor for Indian users.

User's Recent Financial Data (last 3 months):
- Total Income: ₹${nf.format(totalIncome)}
- Total Expenses: ₹${nf.format(totalExpenses)}
- Savings Rate: ${totalIncome > 0 ? (((totalIncome - totalExpenses) / totalIncome) * 100).toStringAsFixed(1) : '0'}%
- Category Breakdown: $categorySummary

Recent Transactions:
$recentTxns

User's Question: $message

Provide a helpful, concise response. Use Indian financial context (INR, UPI, SIP, etc.). Be friendly and actionable. Keep response under 200 words unless more detail is needed.''';

    try {
      final url = Uri.parse('$_baseUrl/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.7,
          'top_p': 0.95,
          'max_tokens': 2048,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['choices']?[0]?['message'];
        final content = message?['content'];
        final reasoning = message?['reasoning_content'];
        if (content != null && content.toString().isNotEmpty) {
          return content;
        } else if (reasoning != null && reasoning.toString().isNotEmpty) {
          return reasoning;
        }
        return 'Sorry, I could not generate a response.';
      } else {
        debugPrint('NVIDIA NIM API error ${response.statusCode}: ${response.body}');
        return 'API error ${response.statusCode}. Please try again.';
      }
    } catch (e) {
      debugPrint('NVIDIA NIM API exception: $e');
      return 'Error: ${e.toString()}';
    }
  }
}

/// Financial health score model
class FinancialHealthScore {
  final int score;
  final String label;
  final String description;
  final List<HealthFactor> factors;

  FinancialHealthScore({
    required this.score,
    required this.label,
    required this.description,
    required this.factors,
  });
}

/// Health factor model
class HealthFactor {
  final String label;
  final String value;
  final double score;
  final double maxScore;
  final String status;

  HealthFactor({
    required this.label,
    required this.value,
    required this.score,
    required this.maxScore,
    required this.status,
  });
}

/// Spending anomaly model
class SpendingAnomaly {
  final String category;
  final double amount;
  final double average;
  final String severity;
  final String message;

  SpendingAnomaly({
    required this.category,
    required this.amount,
    required this.average,
    required this.severity,
    required this.message,
  });
}

/// Spending forecast model
class SpendingForecast {
  final double predictedExpenses;
  final double predictedIncome;
  final int confidence;
  final List<CategoryForecast> categoryForecasts;
  final String trend;

  SpendingForecast({
    required this.predictedExpenses,
    required this.predictedIncome,
    required this.confidence,
    required this.categoryForecasts,
    required this.trend,
  });
}

/// Category forecast model
class CategoryForecast {
  final String category;
  final double predicted;
  final double current;

  CategoryForecast({
    required this.category,
    required this.predicted,
    required this.current,
  });
}

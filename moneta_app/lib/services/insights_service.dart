import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../local/local_storage.dart';
import '../local/local_models.dart';
import 'settings_service.dart';

/// Service for generating AI-powered spending insights using NVIDIA NIM API
class InsightsService {
  static String get _apiKey => SettingsService.nvidiaApiKey;
  static String get _model => SettingsService.nvidiaModel;
  static String get _baseUrl => SettingsService.nvidiaBaseUrl;

  /// Generate comprehensive spending insights for a date range
  static Future<SpendingInsightsResponse> generateInsights({
    required DateTimeRange dateRange,
    bool includeAiInsights = true,
  }) async {
    try {
      final transactions = await _getTransactionsForRange(dateRange);

      if (transactions.isEmpty) {
        return SpendingInsightsResponse(
          localInsights: 'No transactions found for the selected period.',
          aiInsights:
              includeAiInsights
                  ? 'Add some transactions to get personalized insights!'
                  : null,
          metrics: SpendingMetrics.empty(),
          localTips: [
            '📱 Start by adding transactions manually',
            '💡 Connect your SMS for automatic transaction detection',
            '📊 Set up categories for better tracking',
          ],
        );
      }

      final metrics = _calculateSpendingMetrics(transactions);
      final localInsights = _generateLocalInsights(transactions, metrics);
      final localTips = _generateLocalTips(transactions, metrics);

      String? aiInsights;
      if (includeAiInsights) {
        try {
          aiInsights = await _generateAiInsights(
            transactions,
            metrics,
            dateRange,
          );
        } catch (e) {
          debugPrint('AI insights generation failed: $e');
          aiInsights = null;
        }
      }

      return SpendingInsightsResponse(
        localInsights: localInsights,
        aiInsights: aiInsights,
        metrics: metrics,
        localTips: localTips,
      );
    } catch (e) {
      debugPrint('Error generating insights: $e');
      return SpendingInsightsResponse(
        localInsights: 'Error generating insights: ${e.toString()}',
        aiInsights: null,
        metrics: SpendingMetrics.empty(),
        localTips: ['Try again later'],
      );
    }
  }

  /// Get transactions for a specific date range with duplicate filtering
  static Future<List<LocalTxn>> _getTransactionsForRange(
    DateTimeRange range,
  ) async {
    try {
      final allTransactions = LocalStorage.all();
      final rangeTransactions =
          allTransactions
              .where(
                (txn) =>
                    !txn.date.isBefore(range.start) &&
                    !txn.date.isAfter(range.end),
              )
              .toList();

      return _removeDuplicates(rangeTransactions);
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      return [];
    }
  }

  /// Calculate comprehensive spending metrics
  static SpendingMetrics _calculateSpendingMetrics(
    List<LocalTxn> transactions,
  ) {
    double totalDebit = 0;
    double totalCredit = 0;
    final Map<String, double> categorySpending = {};
    final Map<String, double> merchantSpending = {};
    final Map<String, int> merchantCount = {};
    final Map<DateTime, double> dailySpending = {};

    for (final txn in transactions) {
      if (txn.type == 'credit') {
        totalCredit += txn.amount;
      } else {
        totalDebit += txn.amount;
        categorySpending[txn.category] =
            (categorySpending[txn.category] ?? 0) + txn.amount;

        final merchant = txn.party.trim().toLowerCase();
        if (merchant.isNotEmpty) {
          merchantSpending[merchant] =
              (merchantSpending[merchant] ?? 0) + txn.amount;
          merchantCount[merchant] = (merchantCount[merchant] ?? 0) + 1;
        }

        final day = DateTime(txn.date.year, txn.date.month, txn.date.day);
        dailySpending[day] = (dailySpending[day] ?? 0) + txn.amount;
      }
    }

    final balance = totalCredit - totalDebit;
    final savingsRate =
        totalCredit > 0 ? ((totalCredit - totalDebit) / totalCredit) * 100 : 0;

    final topCategories =
        categorySpending.entries
            .map(
              (e) => CategorySpending(
                category: e.key,
                amount: e.value,
                percentage: totalDebit > 0 ? (e.value / totalDebit) * 100 : 0,
              ),
            )
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    final topMerchants =
        merchantSpending.entries
            .map(
              (e) => MerchantSpending(
                merchant: e.key,
                amount: e.value,
                frequency: merchantCount[e.key] ?? 0,
              ),
            )
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    final nonZeroDays =
        dailySpending.values.where((amount) => amount > 0).length;
    final avgDailySpending = nonZeroDays > 0 ? totalDebit / nonZeroDays : 0;

    return SpendingMetrics(
      totalDebit: totalDebit,
      totalCredit: totalCredit,
      balance: balance,
      savingsRate: savingsRate.toDouble(),
      topCategories: topCategories.take(5).toList(),
      topMerchants: topMerchants.take(5).toList(),
      avgDailySpending: avgDailySpending.toDouble(),
      transactionCount: transactions.length,
    );
  }

  /// Generate local insights summary
  static String _generateLocalInsights(
    List<LocalTxn> transactions,
    SpendingMetrics metrics,
  ) {
    final nf = NumberFormat.decimalPattern('en_IN');
    final insights = <String>[];

    insights.add('💳 Total spent: ₹${nf.format(metrics.totalDebit)}');
    insights.add('💰 Total income: ₹${nf.format(metrics.totalCredit)}');
    insights.add('📊 Net balance: ₹${nf.format(metrics.balance)}');

    if (metrics.savingsRate >= 0) {
      insights.add(
        '💎 Savings rate: ${metrics.savingsRate.toStringAsFixed(1)}%',
      );
    } else {
      insights.add(
        '⚠️ Overspent by: ${metrics.savingsRate.abs().toStringAsFixed(1)}%',
      );
    }

    if (metrics.topCategories.isNotEmpty) {
      insights.add('\n🏷️ Top spending categories:');
      for (final cat in metrics.topCategories.take(3)) {
        insights.add(
          '  • ${cat.category}: ₹${nf.format(cat.amount)} (${cat.percentage.toStringAsFixed(1)}%)',
        );
      }
    }

    if (metrics.avgDailySpending > 0) {
      insights.add(
        '\n📅 Average daily spending: ₹${nf.format(metrics.avgDailySpending)}',
      );
    }

    return insights.join('\n');
  }

  /// Generate local tips based on spending patterns
  static List<String> _generateLocalTips(
    List<LocalTxn> transactions,
    SpendingMetrics metrics,
  ) {
    final tips = <String>[];

    if (metrics.savingsRate < 10) {
      tips.add('💡 Low savings rate! Aim for at least 20% savings');
    } else if (metrics.savingsRate < 20) {
      tips.add('📈 Good progress! Try to increase savings to 20%');
    } else {
      tips.add('🌟 Excellent savings rate! Keep it up!');
    }

    for (final cat in metrics.topCategories.take(3)) {
      if (cat.percentage > 30) {
        final tag = _getCategoryTag(cat.category);
        final advice = _getCategoryAdvice(cat.category);
        tips.add(
          '$tag High ${cat.category} spending (${cat.percentage.toStringAsFixed(0)}%). $advice',
        );
      }
    }

    for (final merchant in metrics.topMerchants.take(2)) {
      if (merchant.frequency >= 5) {
        final tag = _getFrequencyTag(merchant.frequency);
        tips.add(
          '$tag Frequent at "${merchant.merchant}" (${merchant.frequency} times). Consider bulk purchases or alternatives.',
        );
      }
    }

    if (metrics.avgDailySpending > 1000) {
      tips.add(
        '📱 High daily spending detected. Try setting daily spend limits.',
      );
    }

    return tips.isNotEmpty
        ? tips
        : ['Keep tracking your expenses for better insights!'];
  }

  /// Generate AI-powered insights using NVIDIA NIM API
  static Future<String> _generateAiInsights(
    List<LocalTxn> transactions,
    SpendingMetrics metrics,
    DateTimeRange dateRange,
  ) async {
    final prompt = _createInsightsPrompt(transactions, metrics, dateRange);
    return await _callNvidiaNimApi(prompt);
  }

  /// Create comprehensive insights prompt
  static String _createInsightsPrompt(
    List<LocalTxn> transactions,
    SpendingMetrics metrics,
    DateTimeRange dateRange,
  ) {
    final nf = NumberFormat.decimalPattern('en_IN');
    final dateFormat = DateFormat('dd MMM yyyy');

    final categoryDetails = metrics.topCategories
        .map(
          (cat) =>
              '${cat.category}: ₹${nf.format(cat.amount)} (${cat.percentage.toStringAsFixed(1)}%)',
        )
        .join('\n');

    final merchantDetails = metrics.topMerchants
        .take(10)
        .map(
          (merchant) =>
              '${merchant.merchant}: ₹${nf.format(merchant.amount)} (${merchant.frequency} times)',
        )
        .join('\n');

    final recentTransactions = transactions
        .where((txn) => txn.type == 'debit')
        .take(20)
        .map(
          (txn) =>
              '${DateFormat('dd/MM').format(txn.date)}: ${txn.category} - ₹${nf.format(txn.amount)} at ${txn.party}',
        )
        .join('\n');

    return '''You are an expert financial advisor analyzing spending patterns for an Indian user.

Analysis Period: ${dateFormat.format(dateRange.start)} to ${dateFormat.format(dateRange.end)}

Financial Overview:
- Total Income: ₹${nf.format(metrics.totalCredit)}
- Total Expenses: ₹${nf.format(metrics.totalDebit)}
- Net Balance: ₹${nf.format(metrics.balance)}
- Savings Rate: ${metrics.savingsRate.toStringAsFixed(1)}%
- Average Daily Spending: ₹${nf.format(metrics.avgDailySpending)}
- Total Transactions: ${metrics.transactionCount}

Top Spending Categories:
$categoryDetails

Frequent Merchants/Services:
$merchantDetails

Recent Transaction Pattern:
$recentTransactions

Provide detailed financial insights covering:

1. **Spending Pattern Analysis**: Identify trends, unusual patterns, and spending habits
2. **Category Optimization**: Specific recommendations for high-spending categories
3. **Behavioral Insights**: Spending frequency patterns and triggers
4. **Savings Opportunities**: Concrete steps to improve savings rate
5. **Budget Recommendations**: Suggested limits for different categories
6. **Investment Suggestions**: If savings rate is good, suggest investment options
7. **Risk Areas**: Identify potential financial risks or concerning patterns

**Format Requirements:**
- Use markdown formatting with headers (##), bullet points (-), and bold text (**text**)
- Be specific with amounts in INR
- Provide actionable, practical advice
- Include both praise for good habits and improvement areas
- Structure as: ## Spending Insights, then sections for different analyses
- Use emojis for visual appeal but keep it professional
- Focus on Indian financial context (UPI payments, local merchants, etc.)

Keep the analysis comprehensive but concise, focusing on the most impactful insights.''';
  }

  /// Call NVIDIA NIM API (OpenAI-compatible)
  static Future<String> _callNvidiaNimApi(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception('NVIDIA_API_KEY not configured. Set it in --dart-define or .env');
    }

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
        // Handle thinking models that return reasoning_content
        final content = message?['content'];
        final reasoning = message?['reasoning_content'];
        if (content != null && content.toString().isNotEmpty) {
          return content;
        } else if (reasoning != null && reasoning.toString().isNotEmpty) {
          return reasoning;
        }
        return 'Unable to generate AI insights at the moment.';
      } else {
        throw Exception('NVIDIA NIM API error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('NVIDIA NIM API error: $e');
      rethrow;
    }
  }

  /// Get category-specific tag emoji
  static String _getCategoryTag(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & beverages':
        return '🍽️';
      case 'transport':
        return '🚗';
      case 'shopping':
        return '🛒';
      case 'entertainment':
        return '🎬';
      case 'bills':
      case 'utilities':
        return '💡';
      case 'healthcare':
        return '🏥';
      case 'education':
        return '📚';
      case 'fuel':
        return '⛽';
      case 'groceries':
        return '🛍️';
      default:
        return '💳';
    }
  }

  /// Get category-specific advice
  static String _getCategoryAdvice(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'food & beverages':
        return 'Try meal prepping or cooking at home more often.';
      case 'transport':
        return 'Consider carpooling, public transport, or combining trips.';
      case 'shopping':
        return 'Make a shopping list and wait 24h before impulse purchases.';
      case 'entertainment':
        return 'Look for free events or set a monthly entertainment budget.';
      case 'bills':
      case 'utilities':
        return 'Review plans and negotiate with providers for better rates.';
      case 'healthcare':
        return 'Consider generic medicines and preventive care.';
      case 'fuel':
        return 'Plan efficient routes and consider carpooling.';
      case 'groceries':
        return 'Buy in bulk, use coupons, and stick to a shopping list.';
      default:
        return 'Track expenses and set monthly limits for this category.';
    }
  }

  /// Get frequency-based tag emoji
  static String _getFrequencyTag(int count) {
    if (count >= 15) return '🔥';
    if (count >= 10) return '⚡';
    if (count >= 5) return '📍';
    return '📝';
  }

  /// Remove duplicate transactions
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
    if (txn1.amount == txn2.amount &&
        txn1.type == txn2.type &&
        txn1.date.difference(txn2.date).abs().inMinutes <= 1) {
      final party1 = txn1.party.trim().toLowerCase();
      final party2 = txn2.party.trim().toLowerCase();

      if (party1 == party2) return true;

      if (party1.isNotEmpty &&
          party2.isNotEmpty &&
          (party1.contains(party2) || party2.contains(party1))) {
        return true;
      }

      if (txn1.raw.trim() == txn2.raw.trim()) return true;
    }

    return false;
  }
}

/// Response model for spending insights
class SpendingInsightsResponse {
  final String localInsights;
  final String? aiInsights;
  final SpendingMetrics metrics;
  final List<String> localTips;

  SpendingInsightsResponse({
    required this.localInsights,
    this.aiInsights,
    required this.metrics,
    required this.localTips,
  });
}

/// Comprehensive spending metrics model
class SpendingMetrics {
  final double totalDebit;
  final double totalCredit;
  final double balance;
  final double savingsRate;
  final List<CategorySpending> topCategories;
  final List<MerchantSpending> topMerchants;
  final double avgDailySpending;
  final int transactionCount;

  SpendingMetrics({
    required this.totalDebit,
    required this.totalCredit,
    required this.balance,
    required this.savingsRate,
    required this.topCategories,
    required this.topMerchants,
    required this.avgDailySpending,
    required this.transactionCount,
  });

  static SpendingMetrics empty() {
    return SpendingMetrics(
      totalDebit: 0,
      totalCredit: 0,
      balance: 0,
      savingsRate: 0,
      topCategories: [],
      topMerchants: [],
      avgDailySpending: 0,
      transactionCount: 0,
    );
  }
}

/// Category spending model
class CategorySpending {
  final String category;
  final double amount;
  final double percentage;

  CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

/// Merchant spending model
class MerchantSpending {
  final String merchant;
  final double amount;
  final int frequency;

  MerchantSpending({
    required this.merchant,
    required this.amount,
    required this.frequency,
  });
}

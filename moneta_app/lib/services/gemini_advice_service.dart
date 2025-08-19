import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../local/local_storage.dart';
import '../local/local_models.dart';

/// Service for getting AI-powered financial advice using Gemini
class GeminiAdviceService {
  static const String _geminiApiKey = 'AIzaSyBEEVjMe01KFNP3taowo3EVbV748B5FsoY';
  static const String _geminiModel = 'gemini-2.0-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Get personalized financial tips based on local spending patterns
  static Future<FinancialTipsResponse> getFinancialTips() async {
    try {
      // Get local transaction data
      final transactions = LocalStorage.all();

      // Filter to last 3 months
      final now = DateTime.now();
      final threeMonthsAgo = now.subtract(const Duration(days: 90));
      final recentTransactions =
          transactions
              .where((txn) => txn.date.isAfter(threeMonthsAgo))
              .toList();

      // Apply duplicate filtering for accurate calculations
      final uniqueTransactions = _removeDuplicates(recentTransactions);

      if (uniqueTransactions.isEmpty) {
        return FinancialTipsResponse(
          tips:
              '''• Start tracking your expenses by adding transactions manually
• Set a monthly budget for different categories like food, transport, and entertainment
• Try to save at least 20% of your income each month
• Build an emergency fund covering 6 months of expenses
• Consider investing in SIP (Systematic Investment Plan) for long-term wealth building
• Review your subscriptions and cancel unused services
• Use cashback and reward programs to save money on purchases''',
          metrics: FinancialMetrics(
            totalIncome: 0,
            totalExpenses: 0,
            currentBalance: 0,
            avgMonthlySpending: 0,
            savingsRate: 0,
            topCategories: [],
          ),
        );
      }

      // Calculate metrics
      final metrics = _calculateMetrics(uniqueTransactions);

      // Create prompt for Gemini
      final prompt = _createFinancialTipsPrompt(metrics, uniqueTransactions);

      // Call Gemini API
      final tips = await _callGeminiAPI(prompt);

      return FinancialTipsResponse(tips: tips, metrics: metrics);
    } catch (e) {
      debugPrint('Error getting financial tips: $e');
      // Return fallback tips
      return FinancialTipsResponse(
        tips: '''## Personal Financial Tips

- **Track Daily Expenses**: Monitor your spending patterns to identify areas for improvement
- **Monthly Budget**: Set a realistic budget and stick to it consistently  
- **Save First**: Aim to save at least **20%** of your income before spending
- **Emergency Fund**: Build a fund covering **6 months** of expenses
- **SIP Investment**: Start a systematic investment plan of **₹5,000-10,000/month** in diversified mutual funds
- **Review Subscriptions**: Cancel unused services and subscriptions to save **₹1,000-2,000/month**
- **Optimize High Categories**: Focus on reducing your top spending categories by **10-15%**''',
        metrics: FinancialMetrics(
          totalIncome: 0,
          totalExpenses: 0,
          currentBalance: 0,
          avgMonthlySpending: 0,
          savingsRate: 0,
          topCategories: [],
        ),
      );
    }
  }

  /// Generate a personalized budget plan
  static Future<BudgetPlanResponse> generateBudgetPlan({
    double targetSavingsRate = 20,
    double? monthlyIncome,
  }) async {
    try {
      final transactions = LocalStorage.all();
      final now = DateTime.now();
      final threeMonthsAgo = now.subtract(const Duration(days: 90));
      final recentTransactions =
          transactions
              .where((txn) => txn.date.isAfter(threeMonthsAgo))
              .toList();

      // Apply duplicate filtering for accurate calculations
      final uniqueTransactions = _removeDuplicates(recentTransactions);

      final metrics = _calculateMetrics(uniqueTransactions);
      final avgMonthlyIncome = monthlyIncome ?? metrics.totalIncome / 3;

      final prompt =
          '''Create a personalized monthly budget plan for an Indian user.

User Details:
- Monthly Income: ₹${avgMonthlyIncome.toStringAsFixed(2)}
- Current Average Monthly Spending: ₹${metrics.avgMonthlySpending.toStringAsFixed(2)}
- Target Savings Rate: ${targetSavingsRate.toStringAsFixed(1)}%
- Top Spending Categories: ${metrics.topCategories.map((cat) => '${cat.category}: ₹${(cat.amount / 3).toStringAsFixed(2)}').join(', ')}

Create a detailed budget plan with:
1. Recommended allocation for each expense category
2. Specific savings targets
3. Emergency fund recommendations
4. Investment suggestions (SIP, FD, etc.)
5. Tips to achieve the target savings rate

Format as a structured budget with amounts and percentages. Be practical and achievable.

**Format Requirements:**
- Use markdown formatting with headers (##), bullet points (-), and bold text (**text**)
- Structure as: ## Monthly Budget Plan, then sections for different allocations
- Include specific amounts in INR''';

      final budgetPlan = await _callGeminiAPI(prompt);

      return BudgetPlanResponse(
        budgetPlan: budgetPlan,
        targetSavingsAmount: (avgMonthlyIncome * targetSavingsRate) / 100,
        currentSavingsRate:
            avgMonthlyIncome > 0
                ? ((avgMonthlyIncome - metrics.avgMonthlySpending) /
                        avgMonthlyIncome) *
                    100
                : 0,
        recommendedExpenseLimit:
            avgMonthlyIncome * (100 - targetSavingsRate) / 100,
      );
    } catch (e) {
      debugPrint('Error generating budget plan: $e');
      return BudgetPlanResponse(
        budgetPlan: '''## Recommended Budget Plan

**Income Allocation:**
- **Savings**: ${targetSavingsRate.toStringAsFixed(1)}%
- **Essential Expenses**: 50-60%
- **Entertainment**: 10-15%
- **Emergency Fund**: 10%

**Category Limits:**
- **Food & Beverages**: 25% of income
- **Transport**: 15% of income
- **Shopping**: 10% of income
- **Bills & Utilities**: 20% of income

**Investment Strategy:**
- Start **SIP** with ₹2,000-5,000/month
- Build **emergency fund** of 6 months expenses
- Consider **ELSS** for tax savings
- Review and adjust monthly''',
        targetSavingsAmount: 0,
        currentSavingsRate: 0,
        recommendedExpenseLimit: 0,
      );
    }
  }

  /// Get investment advice based on user profile
  static Future<InvestmentAdviceResponse> getInvestmentAdvice({
    required String riskTolerance,
    required int investmentHorizon,
    required double monthlyInvestment,
    required int age,
    String financialGoals = 'wealth building',
  }) async {
    try {
      final prompt =
          '''Provide personalized investment advice for an Indian investor.

Investor Profile:
- Age: $age years
- Risk Tolerance: $riskTolerance
- Investment Horizon: $investmentHorizon years
- Monthly Investment Budget: ₹${monthlyInvestment.toStringAsFixed(2)}
- Financial Goals: $financialGoals

Provide specific recommendations including:
1. Asset allocation strategy
2. Recommended mutual funds/investment products
3. SIP recommendations with specific fund categories
4. Tax-saving options (ELSS, PPF, etc.)
5. Portfolio diversification advice
6. Expected returns and growth projections
7. Risk management strategies

Focus on Indian investment options and current market conditions. Be specific with fund categories and allocation percentages.''';

      final advice = await _callGeminiAPI(prompt);

      return InvestmentAdviceResponse(
        investmentAdvice: advice,
        projectedReturns: ProjectedReturns(
          conservative: monthlyInvestment * 12 * investmentHorizon * 1.08,
          moderate: monthlyInvestment * 12 * investmentHorizon * 1.12,
          aggressive: monthlyInvestment * 12 * investmentHorizon * 1.15,
        ),
      );
    } catch (e) {
      debugPrint('Error getting investment advice: $e');
      return InvestmentAdviceResponse(
        investmentAdvice: '''**Investment Recommendations:**

**Asset Allocation:**
• Equity Mutual Funds: ${age < 30
            ? '70-80%'
            : age < 40
            ? '60-70%'
            : '50-60%'}
• Debt Instruments: ${age < 30
            ? '20-30%'
            : age < 40
            ? '30-40%'
            : '40-50%'}

**Recommended Products:**
• Large Cap Funds for stability
• Mid Cap Funds for growth
• ELSS for tax savings
• PPF for long-term security

**Strategy:**
• Start SIP immediately
• Increase investment by 10% annually
• Review portfolio quarterly
• Stay disciplined with long-term view''',
        projectedReturns: ProjectedReturns(
          conservative: monthlyInvestment * 12 * investmentHorizon * 1.08,
          moderate: monthlyInvestment * 12 * investmentHorizon * 1.12,
          aggressive: monthlyInvestment * 12 * investmentHorizon * 1.15,
        ),
      );
    }
  }

  /// Calculate financial metrics from transactions
  static FinancialMetrics _calculateMetrics(List<dynamic> transactions) {
    double totalIncome = 0;
    double totalExpenses = 0;
    double currentBalance = 0;
    Map<String, double> categorySpending = {};

    for (final txn in transactions) {
      final amount = txn.amount ?? 0.0;

      if (txn.type == 'credit') {
        totalIncome += amount;
      } else {
        totalExpenses += amount;
        final category = txn.category ?? 'Other';
        categorySpending[category] = (categorySpending[category] ?? 0) + amount;
      }

      if (txn.balance != null) {
        currentBalance = txn.balance!;
      }
    }

    final topCategories =
        categorySpending.entries
            .map(
              (e) => CategorySpending(
                category: e.key,
                amount: e.value,
                percentage:
                    totalExpenses > 0 ? (e.value / totalExpenses) * 100 : 0,
              ),
            )
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    return FinancialMetrics(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      currentBalance: currentBalance,
      avgMonthlySpending: totalExpenses / 3,
      savingsRate:
          totalIncome > 0
              ? ((totalIncome - totalExpenses) / totalIncome) * 100
              : 0,
      topCategories: topCategories.take(5).toList(),
    );
  }

  /// Create financial tips prompt
  static String _createFinancialTipsPrompt(
    FinancialMetrics metrics,
    List<dynamic> transactions,
  ) {
    return '''You are a financial advisor providing personalized savings tips and money management advice.

User's Financial Profile (Last 3 months):
- Total Income: ₹${metrics.totalIncome.toStringAsFixed(2)}
- Total Expenses: ₹${metrics.totalExpenses.toStringAsFixed(2)}
- Current Balance: ₹${metrics.currentBalance.toStringAsFixed(2)}
- Average Monthly Spending: ₹${metrics.avgMonthlySpending.toStringAsFixed(2)}
- Savings Rate: ${metrics.savingsRate.toStringAsFixed(1)}%

Top Spending Categories:
${metrics.topCategories.map((cat) => '• ${cat.category}: ₹${cat.amount.toStringAsFixed(2)} (${cat.percentage.toStringAsFixed(1)}%)').join('\n')}

Provide 5-7 personalized financial tips focusing on:
1. Specific savings opportunities based on their spending patterns
2. Category-wise optimization suggestions
3. Budgeting recommendations
4. Investment advice if applicable
5. Emergency fund guidance
6. Practical money-saving tips

**Format Requirements:**
- Use markdown formatting with headers (##), bullet points (-), and bold text (**text**)
- Be specific with amounts where relevant
- Keep it actionable and encouraging
- Use Indian financial context (INR, Indian investment options like SIP, FD, etc.)
- Structure as: ## Financial Tips, then bullet points for each tip''';
  }

  /// Call Gemini API
  static Future<String> _callGeminiAPI(String prompt) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/$_geminiModel:generateContent?key=$_geminiApiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ??
            'Unable to generate advice at the moment.';
      } else {
        throw Exception('API call failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Gemini API error: $e');
      throw e;
    }
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

/// Response model for financial tips
class FinancialTipsResponse {
  final String tips;
  final FinancialMetrics metrics;

  FinancialTipsResponse({required this.tips, required this.metrics});

  factory FinancialTipsResponse.fromMap(Map<String, dynamic> map) {
    return FinancialTipsResponse(
      tips: map['tips'] ?? '',
      metrics: FinancialMetrics.fromMap(map['metrics'] ?? {}),
    );
  }
}

/// Financial metrics model
class FinancialMetrics {
  final double totalIncome;
  final double totalExpenses;
  final double currentBalance;
  final double avgMonthlySpending;
  final double savingsRate;
  final List<CategorySpending> topCategories;

  FinancialMetrics({
    required this.totalIncome,
    required this.totalExpenses,
    required this.currentBalance,
    required this.avgMonthlySpending,
    required this.savingsRate,
    required this.topCategories,
  });

  factory FinancialMetrics.fromMap(Map<String, dynamic> map) {
    return FinancialMetrics(
      totalIncome: (map['totalIncome'] ?? 0).toDouble(),
      totalExpenses: (map['totalExpenses'] ?? 0).toDouble(),
      currentBalance: (map['currentBalance'] ?? 0).toDouble(),
      avgMonthlySpending: (map['avgMonthlySpending'] ?? 0).toDouble(),
      savingsRate: (map['savingsRate'] ?? 0).toDouble(),
      topCategories:
          (map['topCategories'] as List?)
              ?.map((e) => CategorySpending.fromMap(e))
              .toList() ??
          [],
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

  factory CategorySpending.fromMap(Map<String, dynamic> map) {
    return CategorySpending(
      category: map['category'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      percentage: (map['percentage'] ?? 0).toDouble(),
    );
  }
}

/// Response model for budget plan
class BudgetPlanResponse {
  final String budgetPlan;
  final double targetSavingsAmount;
  final double currentSavingsRate;
  final double recommendedExpenseLimit;

  BudgetPlanResponse({
    required this.budgetPlan,
    required this.targetSavingsAmount,
    required this.currentSavingsRate,
    required this.recommendedExpenseLimit,
  });

  factory BudgetPlanResponse.fromMap(Map<String, dynamic> map) {
    return BudgetPlanResponse(
      budgetPlan: map['budgetPlan'] ?? '',
      targetSavingsAmount: (map['targetSavingsAmount'] ?? 0).toDouble(),
      currentSavingsRate: (map['currentSavingsRate'] ?? 0).toDouble(),
      recommendedExpenseLimit: (map['recommendedExpenseLimit'] ?? 0).toDouble(),
    );
  }
}

/// Response model for investment advice
class InvestmentAdviceResponse {
  final String investmentAdvice;
  final ProjectedReturns projectedReturns;

  InvestmentAdviceResponse({
    required this.investmentAdvice,
    required this.projectedReturns,
  });

  factory InvestmentAdviceResponse.fromMap(Map<String, dynamic> map) {
    return InvestmentAdviceResponse(
      investmentAdvice: map['investmentAdvice'] ?? '',
      projectedReturns: ProjectedReturns.fromMap(map['projectedReturns'] ?? {}),
    );
  }
}

/// Projected returns model
class ProjectedReturns {
  final double conservative;
  final double moderate;
  final double aggressive;

  ProjectedReturns({
    required this.conservative,
    required this.moderate,
    required this.aggressive,
  });

  factory ProjectedReturns.fromMap(Map<String, dynamic> map) {
    return ProjectedReturns(
      conservative: (map['conservative'] ?? 0).toDouble(),
      moderate: (map['moderate'] ?? 0).toDouble(),
      aggressive: (map['aggressive'] ?? 0).toDouble(),
    );
  }
}

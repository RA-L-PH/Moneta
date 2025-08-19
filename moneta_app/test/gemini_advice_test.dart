import 'package:flutter_test/flutter_test.dart';
import 'package:moneta_app/services/gemini_advice_service.dart';
import 'package:moneta_app/local/local_storage.dart';

void main() {
  group('Gemini Advice Service Tests', () {
    setUpAll(() async {
      // Initialize Hive for testing
      try {
        await LocalStorage.init();
      } catch (e) {
        // Ignore if already initialized
      }
    });

    test('should return fallback tips when no transactions', () async {
      // This test will use fallback tips since there are no transactions in test environment
      final response = await GeminiAdviceService.getFinancialTips();

      expect(response, isNotNull);
      expect(response.tips, isNotEmpty);
      expect(response.tips.toLowerCase(), contains('track'));
      expect(response.metrics, isNotNull);
      expect(response.metrics.totalIncome, equals(0));
      expect(response.metrics.totalExpenses, equals(0));
    });

    test('should return fallback budget plan when no data', () async {
      final response = await GeminiAdviceService.generateBudgetPlan(
        targetSavingsRate: 25,
        monthlyIncome: 50000,
      );

      expect(response, isNotNull);
      expect(response.budgetPlan, isNotEmpty);
      expect(response.budgetPlan.toLowerCase(), contains('budget'));
      expect(response.targetSavingsAmount, equals(0));
    });

    test('should return fallback investment advice', () async {
      final response = await GeminiAdviceService.getInvestmentAdvice(
        riskTolerance: 'moderate',
        investmentHorizon: 10,
        monthlyInvestment: 5000,
        age: 30,
        financialGoals: 'retirement planning',
      );

      expect(response, isNotNull);
      expect(response.investmentAdvice, isNotEmpty);
      expect(response.investmentAdvice.toLowerCase(), contains('investment'));
      expect(response.projectedReturns, isNotNull);
      expect(response.projectedReturns.moderate, greaterThan(0));
    });

    test('should calculate correct projected returns', () async {
      const monthlyInvestment = 10000.0;
      const years = 5;

      final response = await GeminiAdviceService.getInvestmentAdvice(
        riskTolerance: 'moderate',
        investmentHorizon: years,
        monthlyInvestment: monthlyInvestment,
        age: 25,
      );

      // Conservative: 8% annual return
      final expectedConservative = monthlyInvestment * 12 * years * 1.08;
      // Moderate: 12% annual return
      final expectedModerate = monthlyInvestment * 12 * years * 1.12;
      // Aggressive: 15% annual return
      final expectedAggressive = monthlyInvestment * 12 * years * 1.15;

      expect(
        response.projectedReturns.conservative,
        equals(expectedConservative),
      );
      expect(response.projectedReturns.moderate, equals(expectedModerate));
      expect(response.projectedReturns.aggressive, equals(expectedAggressive));
    });

    test('should handle different risk tolerances', () async {
      final lowRisk = await GeminiAdviceService.getInvestmentAdvice(
        riskTolerance: 'low',
        investmentHorizon: 5,
        monthlyInvestment: 5000,
        age: 50,
      );

      final highRisk = await GeminiAdviceService.getInvestmentAdvice(
        riskTolerance: 'high',
        investmentHorizon: 10,
        monthlyInvestment: 5000,
        age: 25,
      );

      expect(lowRisk.investmentAdvice, isNotEmpty);
      expect(highRisk.investmentAdvice, isNotEmpty);
      // Both should return advice, specific content may vary
    });
  });
}

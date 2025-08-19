import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../local/local_storage.dart';
import '../local/local_models.dart';
import '../services/monthly_report_service.dart';
import '../services/dashboard_calculation_service.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check for monthly report generation
    MonthlyReportService.checkAndGenerateReport();

    return ValueListenableBuilder(
      valueListenable: Hive.box<LocalTxn>(LocalStorage.boxName).listenable(),
      builder: (context, Box<LocalTxn> box, _) {
        // Use the new calculation service for duplicate-filtered calculations
        final calculations =
            DashboardCalculationService.getCurrentMonthCalculations();
        final totalDebit = calculations['debited']!;
        final totalCredit = calculations['credited']!;
        final latestBalance = calculations['balance']!;
        final remaining = totalCredit - totalDebit;

        // Get category breakdown with duplicate filtering
        final byCategory =
            DashboardCalculationService.getCurrentMonthCategoryBreakdown();

        final pieSections =
            byCategory.entries.map((e) {
              // Use theme-aware color palette
              final colors = [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
                AppTheme.getExpenseColor(context),
                AppTheme.getWarningColor(context),
                const Color(0xFF9C27B0),
                const Color(0xFF673AB7),
                const Color(0xFF3F51B5),
                const Color(0xFF009688),
              ];
              final color = colors[e.key.hashCode % colors.length];
              return PieChartSectionData(
                value: e.value,
                title: e.key,
                color: color,
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList();

        // Get recent transactions with duplicate filtering
        final recent = DashboardCalculationService.getRecentTransactions(
          limit: 5,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Overview', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _SummaryCard(
                totalDebit: totalDebit,
                totalCredit: totalCredit,
                remaining: remaining,
                latestBalance: latestBalance,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending by category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child:
                            pieSections.isEmpty
                                ? const Center(child: Text('No data'))
                                : PieChart(PieChartData(sections: pieSections)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Recent transactions',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              ...recent.take(5).map((t) {
                return ListTile(
                  title: Text(t.party.isNotEmpty ? t.party : 'Transaction'),
                  subtitle: Text(
                    '${t.category} • ${DateFormat.yMMMd().format(t.date)}',
                  ),
                  trailing: Text(
                    (t.type == 'credit' ? '+' : '-') +
                        t.amount.toStringAsFixed(2),
                    style: TextStyle(
                      color:
                          t.type == 'credit'
                              ? AppTheme.getIncomeColor(context)
                              : AppTheme.getExpenseColor(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double totalDebit;
  final double totalCredit;
  final double remaining;
  final double? latestBalance;
  const _SummaryCard({
    required this.totalDebit,
    required this.totalCredit,
    required this.remaining,
    this.latestBalance,
  });

  @override
  Widget build(BuildContext context) {
    final nfIn = NumberFormat.decimalPattern('en_IN');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _metric(
                  'Debited',
                  '₹${nfIn.format(totalDebit)}',
                  AppTheme.getExpenseColor(context),
                ),
                _metric(
                  'Credited',
                  '₹${nfIn.format(totalCredit)}',
                  AppTheme.getIncomeColor(context),
                ),
                _metric(
                  'Balance',
                  '₹${nfIn.format(latestBalance ?? 0)}',
                  Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            // Remove the current balance section below as it's now integrated above
          ],
        ),
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

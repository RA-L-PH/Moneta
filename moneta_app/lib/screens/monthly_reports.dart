import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../local/local_storage.dart';
import '../local/local_models.dart';
import '../services/monthly_report_service.dart';
import '../theme/app_theme.dart';

class MonthlyReportsScreen extends StatefulWidget {
  const MonthlyReportsScreen({super.key});

  @override
  State<MonthlyReportsScreen> createState() => _MonthlyReportsScreenState();
}

class _MonthlyReportsScreenState extends State<MonthlyReportsScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final reports = LocalStorage.getAllReports();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Reports'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _generateCurrentMonthReport,
            icon:
                _loading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.add),
            tooltip: 'Generate Current Month Report',
          ),
        ],
      ),
      body:
          reports.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No monthly reports available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Reports are automatically generated at the end of each month',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      title: Text(
                        '${report.monthName} ${report.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Net: ₹${(report.totalIncome - report.totalExpense).toStringAsFixed(2)} • ${report.transactionCount} transactions',
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFinancialSummary(report),
                              const SizedBox(height: 16),
                              _buildCategoryBreakdown(report),
                              const SizedBox(height: 16),
                              _buildAISummary(report),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildFinancialSummary(MonthlyReport report) {
    final nfIn = NumberFormat.decimalPattern('en_IN');
    final net = report.totalIncome - report.totalExpense;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Summary',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetric(
              'Income',
              '+₹${nfIn.format(report.totalIncome)}',
              AppTheme.getIncomeColor(context),
            ),
            _buildMetric(
              'Expenses',
              '-₹${nfIn.format(report.totalExpense)}',
              AppTheme.getExpenseColor(context),
            ),
            _buildMetric(
              'Net',
              '₹${nfIn.format(net)}',
              net >= 0
                  ? AppTheme.getSuccessColor(context)
                  : AppTheme.getExpenseColor(context),
            ),
          ],
        ),
        if (report.averageBalance != null) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Average Balance: ₹${nfIn.format(report.averageBalance!)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(MonthlyReport report) {
    if (report.categoryBreakdown.isEmpty) {
      return const SizedBox.shrink();
    }

    final nfIn = NumberFormat.decimalPattern('en_IN');
    final sortedCategories =
        report.categoryBreakdown.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Breakdown',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...sortedCategories.take(5).map((entry) {
          final percentage = (entry.value / report.totalExpense * 100);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(entry.key)),
                Expanded(
                  flex: 2,
                  child: Text(
                    '₹${nfIn.format(entry.value)}',
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAISummary(MonthlyReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI Insights',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Text(report.aiSummary, style: const TextStyle(fontSize: 14)),
        ),
        const SizedBox(height: 8),
        Text(
          'Generated on ${DateFormat.yMMMd().add_jm().format(report.generatedAt)}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _generateCurrentMonthReport() async {
    setState(() => _loading = true);

    try {
      final now = DateTime.now();
      await MonthlyReportService.generateMonthlyReport(now.year, now.month);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Monthly report generated successfully!'),
            backgroundColor: AppTheme.getSuccessColor(context),
          ),
        );
        setState(() {}); // Refresh the list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: AppTheme.getExpenseColor(context),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}

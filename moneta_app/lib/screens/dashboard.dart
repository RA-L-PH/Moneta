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
    MonthlyReportService.checkAndGenerateReport();

    return ValueListenableBuilder(
      valueListenable: Hive.box<LocalTxn>(LocalStorage.boxName).listenable(),
      builder: (context, Box<LocalTxn> box, _) {
        final calc = DashboardCalculationService.getCurrentMonthCalculations();
        final totalDebit = calc['debited']!;
        final totalCredit = calc['credited']!;
        final latestBalance = calc['balance']!;
        final remaining = totalCredit - totalDebit;
        final recent = DashboardCalculationService.getRecentTransactions(limit: 5);

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Balance Hero ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: _BalanceHero(balance: latestBalance, income: totalCredit, expense: totalDebit),
              ),
            ),

            // ─── Stat Cards Row ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: _GlassStat(label: 'Income', value: totalCredit, icon: Icons.arrow_downward_rounded, color: AppTheme.getIncomeColor(context))),
                    const SizedBox(width: 10),
                    Expanded(child: _GlassStat(label: 'Expenses', value: totalDebit, icon: Icons.arrow_upward_rounded, color: AppTheme.getExpenseColor(context))),
                    const SizedBox(width: 10),
                    Expanded(child: _GlassStat(label: 'Saved', value: remaining, icon: Icons.savings_rounded, color: remaining >= 0 ? AppTheme.getSuccessColor(context) : AppTheme.getExpenseColor(context))),
                  ],
                ),
              ),
            ),

            // ─── Monthly Trend Line Graph ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: _GlassSection(
                  title: 'Monthly Trend',
                  icon: Icons.show_chart_rounded,
                  child: SizedBox(
                    height: 220,
                    child: _MonthlyTrendChart(),
                  ),
                ),
              ),
            ),

            // ─── Recent Transactions ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: _GlassSection(
                  title: 'Recent Transactions',
                  icon: Icons.receipt_long_rounded,
                  child: recent.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: Text('No transactions yet')),
                        )
                      : Column(
                          children: recent.map((t) => _GlassTransactionTile(transaction: t)).toList(),
                        ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }
}

// ─── Balance Hero ───────────────────────────────────────────────────────────

class _BalanceHero extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;

  const _BalanceHero({required this.balance, required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF188C4A).withValues(alpha: 0.6), const Color(0xFF297349).withValues(alpha: 0.4)]
              : [const Color(0xFF188C4A).withValues(alpha: 0.5), const Color(0xFF297349).withValues(alpha: 0.3)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/moneta-logo.png',
                  width: 28, height: 28,
                  errorBuilder: (_, __, ___) => Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Total Balance',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '₹${NumberFormat.decimalPattern('en_IN').format(balance)}',
            style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: -1.5),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _MiniStat(label: 'Income', amount: income, icon: Icons.arrow_downward_rounded, color: const Color(0xFF30D158)),
              const SizedBox(width: 20),
              _MiniStat(label: 'Expenses', amount: expense, icon: Icons.arrow_upward_rounded, color: const Color(0xFFFF453A)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _MiniStat({required this.label, required this.amount, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
            Text(
              '₹${NumberFormat.compact().format(amount)}',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Glass Stat Card ────────────────────────────────────────────────────────

class _GlassStat extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;

  const _GlassStat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04), width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? color.withValues(alpha: 0.12) : color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${NumberFormat.compact().format(value)}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color),
          ),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}

// ─── Glass Section Container ────────────────────────────────────────────────

class _GlassSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _GlassSection({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─── Glass Transaction Tile ─────────────────────────────────────────────────

class _GlassTransactionTile extends StatelessWidget {
  final LocalTxn transaction;
  const _GlassTransactionTile({required this.transaction});

  IconData _getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': case 'food & beverages': return Icons.restaurant_rounded;
      case 'transport': return Icons.directions_car_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'bills': case 'bills & utilities': return Icons.receipt_rounded;
      case 'healthcare': return Icons.local_hospital_rounded;
      case 'income': return Icons.account_balance_wallet_rounded;
      default: return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == 'credit';
    final color = isCredit ? AppTheme.getIncomeColor(context) : AppTheme.getExpenseColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.grey.withValues(alpha: 0.1), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(transaction.category), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.party.isNotEmpty ? transaction.party : 'Transaction',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  transaction.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(0)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ─── Monthly Trend Line Chart ──────────────────────────────────────────────

class _MonthlyTrendChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final trend = DashboardCalculationService.getMonthlyTrend(months: 6);
    final isDark = AppTheme.isDark(context);
    final incomeColor = AppTheme.getIncomeColor(context);
    final expenseColor = AppTheme.getExpenseColor(context);

    if (trend.every((m) => m['income'] == 0.0 && m['expense'] == 0.0)) {
      return Center(
        child: Text(
          'No data yet',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    final maxY = trend.fold<double>(0, (max, m) {
      final inc = (m['income'] as double);
      final exp = (m['expense'] as double);
      return inc > exp ? (inc > max ? inc : max) : (exp > max ? exp : max);
    });

    final spotsIncome = <FlSpot>[];
    final spotsExpense = <FlSpot>[];
    for (int i = 0; i < trend.length; i++) {
      spotsIncome.add(FlSpot(i.toDouble(), trend[i]['income'] as double));
      spotsExpense.add(FlSpot(i.toDouble(), trend[i]['expense'] as double));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4, right: 12),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY > 0 ? maxY * 1.2 : 1000,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 4 : 250,
            getDrawingHorizontalLine: (value) => FlLine(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.06),
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 48,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '₹${NumberFormat.compact().format(value)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.35),
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= trend.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      trend[idx]['label'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.45),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => isDark ? const Color(0xFF2C2C2E) : Colors.white,
              tooltipRoundedRadius: 10,
              getTooltipItems: (spots) {
                return spots.map((spot) {
                  final isIncome = spot.barIndex == 0;
                  return LineTooltipItem(
                    '₹${NumberFormat.decimalPattern('en_IN').format(spot.y.toInt())}',
                    TextStyle(
                      color: isIncome ? incomeColor : expenseColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
          lineBarsData: [
            // Income line
            LineChartBarData(
              spots: spotsIncome,
              isCurved: true,
              curveSmoothness: 0.35,
              color: incomeColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(radius: 3.5, color: incomeColor, strokeWidth: 0),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [incomeColor.withValues(alpha: 0.2), incomeColor.withValues(alpha: 0.0)],
                ),
              ),
            ),
            // Expense line
            LineChartBarData(
              spots: spotsExpense,
              isCurved: true,
              curveSmoothness: 0.35,
              color: expenseColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(radius: 3.5, color: expenseColor, strokeWidth: 0),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [expenseColor.withValues(alpha: 0.12), expenseColor.withValues(alpha: 0.0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

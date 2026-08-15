import 'package:flutter/material.dart';
import '../services/gemini_advice_service.dart';
import '../theme/app_theme.dart';
import '../widgets/markdown_renderer.dart';

class FinancialAdviceScreen extends StatefulWidget {
  const FinancialAdviceScreen({super.key});

  @override
  State<FinancialAdviceScreen> createState() => _FinancialAdviceScreenState();
}

class _FinancialAdviceScreenState extends State<FinancialAdviceScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingTips = false;
  bool _isLoadingBudget = false;
  bool _isLoadingInvestment = false;

  FinancialTipsResponse? _tipsResponse;
  BudgetPlanResponse? _budgetResponse;
  InvestmentAdviceResponse? _investmentResponse;

  final _monthlyIncomeController = TextEditingController();
  final _monthlyInvestmentController = TextEditingController(text: '5000');
  final _ageController = TextEditingController(text: '30');
  String _selectedRiskTolerance = 'moderate';
  int _investmentHorizon = 5;
  double _targetSavingsRate = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFinancialTips();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _monthlyIncomeController.dispose();
    _monthlyInvestmentController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadFinancialTips() async {
    setState(() => _isLoadingTips = true);
    try {
      final response = await GeminiAdviceService.getFinancialTips();
      setState(() => _tipsResponse = response);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load tips: $e')));
    } finally {
      setState(() => _isLoadingTips = false);
    }
  }

  Future<void> _generateBudgetPlan() async {
    setState(() => _isLoadingBudget = true);
    try {
      final monthlyIncome = double.tryParse(_monthlyIncomeController.text);
      final response = await GeminiAdviceService.generateBudgetPlan(
        targetSavingsRate: _targetSavingsRate,
        monthlyIncome: monthlyIncome,
      );
      setState(() => _budgetResponse = response);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate budget: $e')));
    } finally {
      setState(() => _isLoadingBudget = false);
    }
  }

  Future<void> _getInvestmentAdvice() async {
    setState(() => _isLoadingInvestment = true);
    try {
      final monthlyInvestment = double.tryParse(_monthlyInvestmentController.text) ?? 5000;
      final age = int.tryParse(_ageController.text) ?? 30;
      final response = await GeminiAdviceService.getInvestmentAdvice(
        riskTolerance: _selectedRiskTolerance,
        investmentHorizon: _investmentHorizon,
        monthlyInvestment: monthlyInvestment,
        age: age,
      );
      setState(() => _investmentResponse = response);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get investment advice: $e')));
    } finally {
      setState(() => _isLoadingInvestment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Financial Advice'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.lightbulb_rounded, size: 20), text: 'Tips'),
            Tab(icon: Icon(Icons.account_balance_wallet_rounded, size: 20), text: 'Budget'),
            Tab(icon: Icon(Icons.show_chart_rounded, size: 20), text: 'Invest'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTipsTab(), _buildBudgetTab(), _buildInvestmentTab()],
      ),
    );
  }

  // ─── Tips Tab ──────────────────────────────────────────────────────────
  Widget _buildTipsTab() {
    return RefreshIndicator(
      onRefresh: _loadFinancialTips,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoadingTips)
              const Center(child: CircularProgressIndicator())
            else if (_tipsResponse != null) ...[
              _GlassMetricsCard(metrics: _tipsResponse!.metrics),
              const SizedBox(height: 16),
              _GlassMarkdownCard(title: 'Personalized Tips', icon: Icons.lightbulb_rounded, iconColor: Colors.amber, child: MarkdownRenderer(text: _tipsResponse!.tips)),
            ] else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lightbulb_rounded, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text('Pull to refresh for financial tips', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Budget Tab ────────────────────────────────────────────────────────
  Widget _buildBudgetTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlassBudgetForm(
            incomeController: _monthlyIncomeController,
            targetSavingsRate: _targetSavingsRate,
            onRateChanged: (v) => setState(() => _targetSavingsRate = v),
            onGenerate: _generateBudgetPlan,
          ),
          const SizedBox(height: 16),
          if (_isLoadingBudget)
            const Center(child: CircularProgressIndicator())
          else if (_budgetResponse != null)
            _GlassBudgetResult(response: _budgetResponse!),
        ],
      ),
    );
  }

  // ─── Investment Tab ────────────────────────────────────────────────────
  Widget _buildInvestmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GlassInvestmentForm(
            ageController: _ageController,
            investmentController: _monthlyInvestmentController,
            selectedRisk: _selectedRiskTolerance,
            onRiskChanged: (v) => setState(() => _selectedRiskTolerance = v!),
            horizon: _investmentHorizon,
            onHorizonChanged: (v) => setState(() => _investmentHorizon = v.round()),
            onGenerate: _getInvestmentAdvice,
          ),
          const SizedBox(height: 16),
          if (_isLoadingInvestment)
            const Center(child: CircularProgressIndicator())
          else if (_investmentResponse != null)
            _GlassInvestmentResult(response: _investmentResponse!),
        ],
      ),
    );
  }
}

// ─── Glass Card Primitives ──────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06), width: 0.5),
      ),
      child: child,
    );
  }
}

class _GlassMetricsCard extends StatelessWidget {
  final FinancialMetrics metrics;
  const _GlassMetricsCard({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Financial Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _metricRow(context, 'Current Balance', '₹${metrics.currentBalance.toStringAsFixed(2)}'),
          _metricRow(context, 'Monthly Spending', '₹${metrics.avgMonthlySpending.toStringAsFixed(2)}'),
          _metricRow(context, 'Savings Rate', '${metrics.savingsRate.toStringAsFixed(1)}%'),
          if (metrics.topCategories.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Top Spending Categories', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...metrics.topCategories.take(3).map((cat) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(cat.category, style: Theme.of(context).textTheme.bodyMedium)),
                  Text('₹${cat.amount.toStringAsFixed(0)} (${cat.percentage.toStringAsFixed(1)}%)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _metricRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _GlassMarkdownCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;
  const _GlassMarkdownCard({required this.title, required this.icon, this.iconColor, required this.child});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor ?? Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _GlassBudgetForm extends StatelessWidget {
  final TextEditingController incomeController;
  final double targetSavingsRate;
  final ValueChanged<double> onRateChanged;
  final VoidCallback onGenerate;

  const _GlassBudgetForm({required this.incomeController, required this.targetSavingsRate, required this.onRateChanged, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Budget Plan Settings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _formField(context, controller: incomeController, label: 'Monthly Income (₹)', icon: Icons.currency_rupee_rounded),
          const SizedBox(height: 16),
          Text('Target Savings Rate: ${targetSavingsRate.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          Slider(
            value: targetSavingsRate,
            min: 5, max: 50, divisions: 9,
            activeColor: colorScheme.primary,
            onChanged: onRateChanged,
          ),
          const SizedBox(height: 12),
          _glassButton(context, label: 'Generate Budget Plan', icon: Icons.auto_awesome_rounded, onTap: onGenerate),
        ],
      ),
    );
  }

  Widget _formField(BuildContext context, {required TextEditingController controller, required String label, required IconData icon}) {
    final isDark = AppTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06), width: 0.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _glassButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _GlassBudgetResult extends StatelessWidget {
  final BudgetPlanResponse response;
  const _GlassBudgetResult({required this.response});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Budget Plan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          _row(context, 'Target Savings', '₹${response.targetSavingsAmount.toStringAsFixed(2)}'),
          _row(context, 'Current Savings Rate', '${response.currentSavingsRate.toStringAsFixed(1)}%'),
          _row(context, 'Expense Limit', '₹${response.recommendedExpenseLimit.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          MarkdownRenderer(text: response.budgetPlan),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _GlassInvestmentForm extends StatelessWidget {
  final TextEditingController ageController;
  final TextEditingController investmentController;
  final String selectedRisk;
  final ValueChanged<String?> onRiskChanged;
  final int horizon;
  final ValueChanged<double> onHorizonChanged;
  final VoidCallback onGenerate;

  const _GlassInvestmentForm({
    required this.ageController, required this.investmentController,
    required this.selectedRisk, required this.onRiskChanged,
    required this.horizon, required this.onHorizonChanged,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = AppTheme.isDark(context);

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Investment Profile', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _miniField(context, controller: ageController, label: 'Age', isDark: isDark)),
              const SizedBox(width: 12),
              Expanded(child: _miniField(context, controller: investmentController, label: 'Monthly Investment (₹)', isDark: isDark)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Risk Tolerance', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06), width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: DropdownButton<String>(
              value: selectedRisk,
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Conservative (Low Risk)')),
                DropdownMenuItem(value: 'moderate', child: Text('Moderate Risk')),
                DropdownMenuItem(value: 'high', child: Text('Aggressive (High Risk)')),
              ],
              onChanged: onRiskChanged,
            ),
          ),
          const SizedBox(height: 16),
          Text('Investment Horizon: $horizon years', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          Slider(
            value: horizon.toDouble(),
            min: 1, max: 30, divisions: 29,
            activeColor: colorScheme.primary,
            onChanged: onHorizonChanged,
          ),
          const SizedBox(height: 12),
          _glassButton(context, label: 'Get Investment Advice', icon: Icons.auto_awesome_rounded, onTap: onGenerate),
        ],
      ),
    );
  }

  Widget _miniField(BuildContext context, {required TextEditingController controller, required String label, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06), width: 0.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: Theme.of(context).textTheme.bodyMedium,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _glassButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _GlassInvestmentResult extends StatelessWidget {
  final InvestmentAdviceResponse response;
  const _GlassInvestmentResult({required this.response});

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Investment Advice', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Text('Projected Returns:', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _row(context, 'Conservative (8%)', '₹${response.projectedReturns.conservative.toStringAsFixed(0)}'),
          _row(context, 'Moderate (12%)', '₹${response.projectedReturns.moderate.toStringAsFixed(0)}'),
          _row(context, 'Aggressive (15%)', '₹${response.projectedReturns.aggressive.toStringAsFixed(0)}'),
          const SizedBox(height: 16),
          MarkdownRenderer(text: response.investmentAdvice),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

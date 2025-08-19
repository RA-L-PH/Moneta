import 'package:flutter/material.dart';
import '../services/gemini_advice_service.dart';
import '../widgets/markdown_renderer.dart';

class FinancialAdviceScreen extends StatefulWidget {
  const FinancialAdviceScreen({Key? key}) : super(key: key);

  @override
  State<FinancialAdviceScreen> createState() => _FinancialAdviceScreenState();
}

class _FinancialAdviceScreenState extends State<FinancialAdviceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingTips = false;
  bool _isLoadingBudget = false;
  bool _isLoadingInvestment = false;

  FinancialTipsResponse? _tipsResponse;
  BudgetPlanResponse? _budgetResponse;
  InvestmentAdviceResponse? _investmentResponse;

  // Investment form fields
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
    // Load tips immediately
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
      _showErrorSnackBar('Failed to load financial tips: $e');
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
      _showErrorSnackBar('Failed to generate budget plan: $e');
    } finally {
      setState(() => _isLoadingBudget = false);
    }
  }

  Future<void> _getInvestmentAdvice() async {
    setState(() => _isLoadingInvestment = true);
    try {
      final monthlyInvestment =
          double.tryParse(_monthlyInvestmentController.text) ?? 5000;
      final age = int.tryParse(_ageController.text) ?? 30;

      final response = await GeminiAdviceService.getInvestmentAdvice(
        riskTolerance: _selectedRiskTolerance,
        investmentHorizon: _investmentHorizon,
        monthlyInvestment: monthlyInvestment,
        age: age,
      );
      setState(() => _investmentResponse = response);
    } catch (e) {
      _showErrorSnackBar('Failed to get investment advice: $e');
    } finally {
      setState(() => _isLoadingInvestment = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Advice'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.lightbulb), text: 'Tips'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Budget'),
            Tab(icon: Icon(Icons.trending_up), text: 'Investment'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTipsTab(), _buildBudgetTab(), _buildInvestmentTab()],
      ),
    );
  }

  Widget _buildTipsTab() {
    return RefreshIndicator(
      onRefresh: _loadFinancialTips,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoadingTips)
              const Center(child: CircularProgressIndicator())
            else if (_tipsResponse != null) ...[
              _buildMetricsCard(_tipsResponse!.metrics),
              const SizedBox(height: 16),
              _buildTipsCard(_tipsResponse!.tips),
            ] else
              const Center(child: Text('Pull to refresh for financial tips')),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBudgetForm(),
          const SizedBox(height: 16),
          if (_isLoadingBudget)
            const Center(child: CircularProgressIndicator())
          else if (_budgetResponse != null)
            _buildBudgetResultCard(_budgetResponse!),
        ],
      ),
    );
  }

  Widget _buildInvestmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInvestmentForm(),
          const SizedBox(height: 16),
          if (_isLoadingInvestment)
            const Center(child: CircularProgressIndicator())
          else if (_investmentResponse != null)
            _buildInvestmentResultCard(_investmentResponse!),
        ],
      ),
    );
  }

  Widget _buildMetricsCard(FinancialMetrics metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Financial Overview',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              'Current Balance',
              '₹${metrics.currentBalance.toStringAsFixed(2)}',
            ),
            _buildMetricRow(
              'Monthly Spending',
              '₹${metrics.avgMonthlySpending.toStringAsFixed(2)}',
            ),
            _buildMetricRow(
              'Savings Rate',
              '${metrics.savingsRate.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 12),
            if (metrics.topCategories.isNotEmpty) ...[
              Text(
                'Top Spending Categories',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...metrics.topCategories
                  .take(3)
                  .map(
                    (cat) => _buildCategoryRow(
                      cat.category,
                      cat.amount,
                      cat.percentage,
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String category, double amount, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category),
          Text(
            '₹${amount.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(String tips) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Personalized Tips',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MarkdownRenderer(text: tips),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Plan Settings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _monthlyIncomeController,
              decoration: const InputDecoration(
                labelText: 'Monthly Income (₹)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text(
              'Target Savings Rate: ${_targetSavingsRate.toStringAsFixed(0)}%',
            ),
            Slider(
              value: _targetSavingsRate,
              min: 5,
              max: 50,
              divisions: 9,
              onChanged: (value) => setState(() => _targetSavingsRate = value),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _generateBudgetPlan,
                child: const Text('Generate Budget Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Profile',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _monthlyInvestmentController,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Investment (₹)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Risk Tolerance'),
            DropdownButton<String>(
              value: _selectedRiskTolerance,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'low',
                  child: Text('Conservative (Low Risk)'),
                ),
                DropdownMenuItem(
                  value: 'moderate',
                  child: Text('Moderate Risk'),
                ),
                DropdownMenuItem(
                  value: 'high',
                  child: Text('Aggressive (High Risk)'),
                ),
              ],
              onChanged:
                  (value) => setState(() => _selectedRiskTolerance = value!),
            ),
            const SizedBox(height: 16),
            Text('Investment Horizon: $_investmentHorizon years'),
            Slider(
              value: _investmentHorizon.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              onChanged:
                  (value) => setState(() => _investmentHorizon = value.round()),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _getInvestmentAdvice,
                child: const Text('Get Investment Advice'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetResultCard(BudgetPlanResponse response) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Budget Plan',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              'Target Savings',
              '₹${response.targetSavingsAmount.toStringAsFixed(2)}',
            ),
            _buildMetricRow(
              'Current Savings Rate',
              '${response.currentSavingsRate.toStringAsFixed(1)}%',
            ),
            _buildMetricRow(
              'Expense Limit',
              '₹${response.recommendedExpenseLimit.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16),
            MarkdownRenderer(text: response.budgetPlan),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentResultCard(InvestmentAdviceResponse response) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Investment Advice',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Projected Returns:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _buildMetricRow(
              'Conservative (8%)',
              '₹${response.projectedReturns.conservative.toStringAsFixed(0)}',
            ),
            _buildMetricRow(
              'Moderate (12%)',
              '₹${response.projectedReturns.moderate.toStringAsFixed(0)}',
            ),
            _buildMetricRow(
              'Aggressive (15%)',
              '₹${response.projectedReturns.aggressive.toStringAsFixed(0)}',
            ),
            const SizedBox(height: 16),
            MarkdownRenderer(text: response.investmentAdvice),
          ],
        ),
      ),
    );
  }
}

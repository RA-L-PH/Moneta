import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'transactions.dart';
import 'insights.dart';
import 'add_expense.dart';
import 'monthly_reports.dart';
import 'sms_parser_test_screen.dart';
import 'financial_advice_screen.dart';
import '../theme/theme_controller.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _pages = const [
    DashboardScreen(),
    TransactionsScreen(),
    InsightsScreen(),
  ];

  // No auto-SMS listener to avoid plugin conflicts.
  @override
  void initState() {
    super.initState();
    // Start SMS capture once on entering home
    // ignore: unawaited_futures
    Future.delayed(Duration.zero, () async {
      try {
        // Lazy import to avoid issues on web/desktop
        // ignore: avoid_dynamic_calls
        // ignore: unnecessary_import
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/moneta_logo.png',
              width: 28,
              height: 28,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
            const Text('Moneta'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Financial Advice',
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FinancialAdviceScreen(),
                  ),
                ),
            icon: const Icon(Icons.psychology),
          ),
          IconButton(
            tooltip: 'SMS Parser Test',
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SmsParserTestScreen(),
                  ),
                ),
            icon: const Icon(Icons.sms),
          ),
          IconButton(
            tooltip: 'Monthly Reports',
            onPressed:
                () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MonthlyReportsScreen(),
                  ),
                ),
            icon: const Icon(Icons.description),
          ),
          IconButton(
            tooltip:
                theme.mode == ThemeMode.dark
                    ? 'Switch to light mode'
                    : 'Switch to dark mode',
            onPressed: () {
              theme.toggle();
              // Show a subtle feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    theme.mode == ThemeMode.dark
                        ? '🌙 Dark mode enabled'
                        : '☀️ Light mode enabled',
                  ),
                  duration: const Duration(milliseconds: 1500),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                theme.mode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
                key: ValueKey(theme.mode),
              ),
            ),
          ),
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          // Index 3 was logout previously (Firebase). In local-only mode, no-op or show info.
          if (i == 3) {
            showDialog(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: const Text('Local Mode'),
                    content: const Text(
                      'All your data is stored locally on this device. No cloud account to sign out from.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
            );
            return;
          }
          setState(() => _index = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'Info',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

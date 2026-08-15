import 'dart:ui';
import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'transactions.dart';
import 'insights.dart';
import 'add_expense.dart';
import 'ai_assistant_screen.dart';
import 'settings_screen.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../theme/theme_controller.dart';

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
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final isDark = AppTheme.isDark(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          // ─── Top Bar (solid, no blur) ──────────────────────────────────
          Container(
            color: isDark ? const Color(0xFF000000) : Theme.of(context).scaffoldBackgroundColor,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                          'assets/images/moneta-logo.png',
                          width: 28, height: 28,
                          errorBuilder: (_, __, ___) => Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.7)]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('Moneta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: colorScheme.onSurface)),
                      const Spacer(),
                      // AI Chat
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen())),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.chat_bubble_outline_rounded, size: 20, color: colorScheme.onSurface),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Theme toggle
                      GestureDetector(
                        onTap: () async {
                          await theme.toggle();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(theme.mode == ThemeMode.dark ? 'Dark mode on' : 'Light mode on'),
                                duration: const Duration(milliseconds: 1200),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            theme.mode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            size: 20, color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Page Content ───────────────────────────────────────────────
          Expanded(child: _pages[_index]),
        ],
      ),
      // ─── Floating Pill Bottom Nav (Frosted Blur) ─────────────────────────
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.6),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  _PillNavItem(
                    icon: Icons.space_dashboard_outlined,
                    activeIcon: Icons.space_dashboard_rounded,
                    label: 'Dashboard',
                    selected: _index == 0,
                    onTap: () => setState(() => _index = 0),
                  ),
                  _PillNavItem(
                    icon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long_rounded,
                    label: 'History',
                    selected: _index == 1,
                    onTap: () => setState(() => _index = 1),
                  ),
                  // Center Add Button
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
                    ),
                  ),
                  _PillNavItem(
                    icon: Icons.insights_outlined,
                    activeIcon: Icons.insights_rounded,
                    label: 'Insights',
                    selected: _index == 2,
                    onTap: () => setState(() => _index = 2),
                  ),
                  _PillNavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings_rounded,
                    label: 'Settings',
                    selected: _index == 3,
                    onTap: () => setState(() => _index = 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _PillNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PillNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? activeIcon : icon,
              size: 24,
              color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

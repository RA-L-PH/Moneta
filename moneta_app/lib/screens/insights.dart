import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/insights_service.dart';
import '../theme/app_theme.dart';
import '../widgets/markdown_renderer.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  DateTimeRange _range = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 6)),
    end: DateTime.now(),
  );

  SpendingInsightsResponse? _insights;
  bool _loading = false;
  String? _error;
  bool _showAiInsights = true;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    setState(() { _loading = true; _error = null; });
    try {
      final insights = await InsightsService.generateInsights(
        dateRange: _range,
        includeAiInsights: _showAiInsights,
      );
      setState(() { _insights = insights; });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ─── Header ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Insights',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat.MMMd().format(_range.start)} – ${DateFormat.MMMd().format(_range.end)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                // Date range button
                GestureDetector(
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      initialDateRange: _range,
                    );
                    if (picked != null) { setState(() => _range = picked); _generate(); }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.date_range_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 8),
                // Generate button
                GestureDetector(
                  onTap: _loading ? null : _generate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Generate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── AI Toggle ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.03), width: 0.5),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Text('AI-Powered Insights', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: _showAiInsights,
                      onChanged: (v) { setState(() => _showAiInsights = v); _generate(); },
                      activeThumbColor: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ─── Loading ─────────────────────────────────────────────────────
        if (_loading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),

        // ─── Error ───────────────────────────────────────────────────────
        if (_error != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.error.withValues(alpha: 0.2), width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: TextStyle(color: colorScheme.error, fontSize: 13))),
                  ],
                ),
              ),
            ),
          ),

        // ─── Insights Content ─────────────────────────────────────────────
        if (_insights != null) ...[
          // Local Insights
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: _GlassInsightCard(
                title: 'Quick Overview',
                icon: Icons.analytics_rounded,
                child: Text(_insights!.localInsights),
              ),
            ),
          ),

          // Local Tips
          if (_insights!.localTips.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: _GlassInsightCard(
                  title: 'Smart Tips',
                  icon: Icons.lightbulb_rounded,
                  child: Column(
                    children: _insights!.localTips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(tip, style: Theme.of(context).textTheme.bodyMedium)),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ),

          // AI Insights
          if (_insights!.aiInsights != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: _GlassInsightCard(
                  title: 'AI Insights',
                  icon: Icons.auto_awesome_rounded,
                  badge: 'AI',
                  child: MarkdownRenderer(text: _insights!.aiInsights!),
                ),
              ),
            ),
        ],

        // ─── Empty State ──────────────────────────────────────────────────
        if (_insights == null && !_loading && _error == null)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.insights_rounded, size: 56, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  Text('Generate Insights', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Tap Generate to analyze your spending',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _GlassInsightCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final String? badge;

  const _GlassInsightCard({required this.title, required this.icon, required this.child, this.badge});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final colorScheme = Theme.of(context).colorScheme;

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
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.2)),
              if (badge != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

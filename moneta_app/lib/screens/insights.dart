import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/insights_service.dart';
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
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final insights = await InsightsService.generateInsights(
        dateRange: _range,
        includeAiInsights: _showAiInsights,
      );

      setState(() {
        _insights = insights;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date range and controls
          Row(
            children: [
              Expanded(
                child: Text(
                  '${DateFormat.yMMMd().format(_range.start)} - ${DateFormat.yMMMd().format(_range.end)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDateRange: _range,
                  );
                  if (picked != null) {
                    setState(() => _range = picked);
                    _generate();
                  }
                },
                child: const Text('Pick range'),
              ),
              FilledButton(
                onPressed: _loading ? null : _generate,
                child:
                    _loading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('Generate'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // AI Insights Toggle
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text('AI-Powered Insights'),
              const Spacer(),
              Switch(
                value: _showAiInsights,
                onChanged: (value) {
                  setState(() => _showAiInsights = value);
                  _generate();
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Loading indicator
          if (_loading) const LinearProgressIndicator(),

          // Error display
          if (_error != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Insights display
          if (_insights != null) ...[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Local Insights
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.analytics,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Quick Overview',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(_insights!.localInsights),

                            if (_insights!.localTips.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Smart Tips',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ..._insights!.localTips.map(
                                (tip) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text('• $tip'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // AI Insights
                    if (_insights!.aiInsights != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.psychology,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'AI Insights',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'AI',
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              MarkdownRenderer(text: _insights!.aiInsights!),
                            ],
                          ),
                        ),
                      ),
                    ] else if (_showAiInsights) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.cloud_off,
                                size: 48,
                                color: Theme.of(context).disabledColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'AI insights unavailable',
                                style: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Check your internet connection',
                                style: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ] else if (!_loading) ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insights,
                      size: 64,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Generate Insights',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the Generate button to analyze your spending patterns',
                      style: TextStyle(color: Theme.of(context).disabledColor),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

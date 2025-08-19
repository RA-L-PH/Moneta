import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../local/local_storage.dart';
import '../local/local_models.dart';
import '../theme/app_theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _query = '';
  DateTimeRange? _dateRange;
  String _filterType = 'all'; // 'all', 'debit', 'credit'

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search description/category/amount',
                ),
                onChanged:
                    (v) => setState(() => _query = v.trim().toLowerCase()),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _filterType,
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(
                          value: 'debit',
                          child: Text('Expenses'),
                        ),
                        DropdownMenuItem(
                          value: 'credit',
                          child: Text('Income'),
                        ),
                      ],
                      onChanged:
                          (value) => setState(() => _filterType = value!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: _pickDateRange,
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _dateRange == null
                            ? 'Select Date Range'
                            : '${DateFormat.MMMd().format(_dateRange!.start)} - ${DateFormat.MMMd().format(_dateRange!.end)}',
                      ),
                    ),
                  ),
                  if (_dateRange != null)
                    IconButton(
                      onPressed: () => setState(() => _dateRange = null),
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear date filter',
                    ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable:
                Hive.box<LocalTxn>(LocalStorage.boxName).listenable(),
            builder: (context, Box<LocalTxn> box, _) {
              var items = box.values.toList().cast<LocalTxn>();

              // Apply filters
              if (_filterType != 'all') {
                items = items.where((t) => t.type == _filterType).toList();
              }

              if (_dateRange != null) {
                items =
                    items
                        .where(
                          (t) =>
                              !t.date.isBefore(_dateRange!.start) &&
                              !t.date.isAfter(
                                _dateRange!.end.add(const Duration(days: 1)),
                              ),
                        )
                        .toList();
              }

              items.sort((a, b) => b.date.compareTo(a.date));
              final nfIn = NumberFormat.decimalPattern('en_IN');

              if (_query.isNotEmpty) {
                items =
                    items.where((t) {
                      final desc = (t.party).toLowerCase();
                      final cat = (t.category).toLowerCase();
                      final amt = t.amount.toStringAsFixed(2);
                      return desc.contains(_query) ||
                          cat.contains(_query) ||
                          amt.contains(_query);
                    }).toList();
              }

              if (items.isEmpty) {
                return const Center(child: Text('No transactions found'));
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, i) {
                  final t = items[i];
                  final amount = t.amount;
                  final type = t.type;
                  final balance = t.balance;
                  final dt = t.date;
                  return ListTile(
                    isThreeLine: balance != null || type == 'debit',
                    leading: CircleAvatar(
                      backgroundColor:
                          type == 'credit'
                              ? AppTheme.getIncomeColor(
                                context,
                              ).withOpacity(0.2)
                              : AppTheme.getExpenseColor(
                                context,
                              ).withOpacity(0.2),
                      child: Icon(
                        type == 'credit' ? Icons.south_west : Icons.north_east,
                        color:
                            type == 'credit'
                                ? AppTheme.getIncomeColor(context)
                                : AppTheme.getExpenseColor(context),
                      ),
                    ),
                    title: Text(t.party.isNotEmpty ? t.party : 'Transaction'),
                    subtitle: Text(
                      '${t.category} • ${DateFormat.yMMMd().add_jm().format(dt)}${balance != null ? ' • Bal: ${nfIn.format(balance)}' : ''}',
                      style: TextStyle(
                        fontWeight:
                            balance != null ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          (type == 'credit' ? '+' : '-') + nfIn.format(amount),
                          style: TextStyle(
                            color:
                                type == 'credit'
                                    ? AppTheme.getIncomeColor(context)
                                    : AppTheme.getExpenseColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (type == 'debit')
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 28),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => _editTagLocal(context, t),
                            child: const Text('Edit Tag'),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  Future<void> _editTagLocal(BuildContext context, LocalTxn txn) async {
    final categories = LocalStorage.getAllCategories();
    final current = txn.category;

    String? selectedCategory = current;
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: categories.contains(current) ? current : null,
                  decoration: const InputDecoration(
                    labelText: 'Select Category',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                  onChanged: (value) => selectedCategory = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Or enter custom category',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => selectedCategory = value.trim(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, selectedCategory),
                child: const Text('Save'),
              ),
            ],
          ),
    );

    if (result != null && result.isNotEmpty) {
      txn.category = result;
      await txn.save();
    }
  }
}

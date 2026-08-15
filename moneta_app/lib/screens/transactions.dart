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
  String _filterType = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Column(
      children: [
        // ─── Search & Filters ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            children: [
              // Glass search bar
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04), width: 0.5),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(Icons.search_rounded, size: 20),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Filter pills
              Row(
                children: [
                  _GlassPill(label: 'All', selected: _filterType == 'all', onTap: () => setState(() => _filterType = 'all')),
                  const SizedBox(width: 6),
                  _GlassPill(label: 'Expenses', selected: _filterType == 'debit', onTap: () => setState(() => _filterType = 'debit'), color: AppTheme.getExpenseColor(context)),
                  const SizedBox(width: 6),
                  _GlassPill(label: 'Income', selected: _filterType == 'credit', onTap: () => setState(() => _filterType = 'credit'), color: AppTheme.getIncomeColor(context)),
                  const Spacer(),
                  if (_dateRange != null)
                    GestureDetector(
                      onTap: () => setState(() => _dateRange = null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.close_rounded, size: 16, color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  if (_dateRange != null) const SizedBox(width: 6),
                  GestureDetector(
                    onTap: _pickDateRange,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _dateRange != null
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
                            : isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.date_range_rounded, size: 18, color: _dateRange != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
              if (_dateRange != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${DateFormat.MMMd().format(_dateRange!.start)} – ${DateFormat.MMMd().format(_dateRange!.end)}',
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ─── Transaction List ─────────────────────────────────────────────
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: Hive.box<LocalTxn>(LocalStorage.boxName).listenable(),
            builder: (context, Box<LocalTxn> box, _) {
              var items = box.values.toList().cast<LocalTxn>();

              if (_filterType != 'all') items = items.where((t) => t.type == _filterType).toList();
              if (_dateRange != null) {
                items = items.where((t) =>
                    !t.date.isBefore(_dateRange!.start) &&
                    !t.date.isAfter(_dateRange!.end.add(const Duration(days: 1)))).toList();
              }
              items.sort((a, b) => b.date.compareTo(a.date));
              if (_query.isNotEmpty) {
                items = items.where((t) =>
                    t.party.toLowerCase().contains(_query) ||
                    t.category.toLowerCase().contains(_query) ||
                    t.amount.toStringAsFixed(2).contains(_query)).toList();
              }

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_rounded, size: 56, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('No transactions found', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                );
              }

              // Group by date
              final grouped = <String, List<LocalTxn>>{};
              for (final t in items) {
                final key = DateFormat.yMMMd().format(t.date);
                grouped.putIfAbsent(key, () => []).add(t);
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final dateKey = grouped.keys.elementAt(index);
                  final txns = grouped[dateKey]!;
                  final dayTotal = txns.fold<double>(0, (sum, t) => sum + (t.type == 'debit' ? -t.amount : t.amount));
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            Text(dateKey, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(
                              '${dayTotal >= 0 ? '+' : ''}₹${NumberFormat.compact().format(dayTotal)}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: dayTotal >= 0 ? AppTheme.getIncomeColor(context) : AppTheme.getExpenseColor(context)),
                            ),
                          ],
                        ),
                      ),
                      ...txns.map((t) => _TransactionTile(transaction: t)),
                    ],
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
    if (picked != null) setState(() => _dateRange = picked);
  }
}

class _GlassPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _GlassPill({required this.label, required this.selected, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final accent = color ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.15) : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? accent.withValues(alpha: 0.4) : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06), width: 0.5),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: selected ? accent : Theme.of(context).colorScheme.onSurfaceVariant)),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final LocalTxn transaction;
  const _TransactionTile({required this.transaction});

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
    final isDark = AppTheme.isDark(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Dismissible(
          key: ValueKey(transaction.key),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(Icons.edit_rounded, color: Theme.of(context).colorScheme.primary, size: 22),
          ),
          confirmDismiss: (_) async { _editTransaction(context, transaction); return false; },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.5),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.03), width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
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
                      const SizedBox(height: 2),
                      Text(
                        '${transaction.category} • ${DateFormat.jm().format(transaction.date)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
          ),
        ),
      ),
    );
  }

  Future<void> _editTransaction(BuildContext context, LocalTxn txn) async {
    final categories = LocalStorage.getAllCategories();
    String selectedCategory = txn.category;
    String selectedParty = txn.party;
    String amountText = txn.amount.toStringAsFixed(2);
    String selectedType = txn.type;
    String description = txn.raw;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Amount
                TextFormField(
                  initialValue: amountText,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => amountText = v.trim(),
                ),
                const SizedBox(height: 12),
                // Party / Recipient
                TextFormField(
                  initialValue: selectedParty,
                  decoration: const InputDecoration(
                    labelText: 'Recipient / Payee',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => selectedParty = v.trim(),
                ),
                const SizedBox(height: 12),
                // Description / What it was for
                TextFormField(
                  initialValue: description,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'What was this for?',
                    hintText: 'e.g. Lunch with friends, electricity bill...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => description = v.trim(),
                ),
                const SizedBox(height: 12),
                // Type
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'debit', child: Text('Expense')),
                    DropdownMenuItem(value: 'credit', child: Text('Income')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedType = v);
                  },
                ),
                const SizedBox(height: 12),
                // Category
                DropdownButtonFormField<String>(
                  initialValue: categories.contains(selectedCategory) ? selectedCategory : null,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedCategory = v);
                  },
                ),
                const SizedBox(height: 8),
                // Custom category
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Or type custom category',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    if (v.trim().isNotEmpty) setDialogState(() => selectedCategory = v.trim());
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, {
                'amount': amountText,
                'party': selectedParty,
                'category': selectedCategory,
                'type': selectedType,
                'description': description,
              }),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      final newAmount = double.tryParse(result['amount'] ?? '');
      if (newAmount != null && newAmount > 0) {
        txn.amount = newAmount;
      }
      if ((result['party'] ?? '').isNotEmpty) {
        txn.party = result['party']!;
      }
      if ((result['category'] ?? '').isNotEmpty) {
        txn.category = result['category']!;
      }
      if (result['type'] == 'debit' || result['type'] == 'credit') {
        txn.type = result['type']!;
      }
      if ((result['description'] ?? '').isNotEmpty) {
        txn.raw = result['description']!;
      }
      await txn.save();
    }
  }
}

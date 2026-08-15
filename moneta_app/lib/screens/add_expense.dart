import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../local/local_models.dart';
import '../local/local_storage.dart';
import '../services/widget_service.dart';
import '../theme/app_theme.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'Food';
  DateTime _date = DateTime.now();
  String _type = 'debit';
  bool _saving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final t = LocalTxn(
        amount: double.parse(_amountCtrl.text),
        type: _type,
        party: _descCtrl.text.trim().isEmpty ? 'Manual' : _descCtrl.text.trim(),
        date: _date,
        category: _category,
        raw: 'manual-entry',
      );
      await LocalStorage.upsert(t);
      await WidgetService.updateTodayTotals();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Transaction'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ─── Amount Input (Glass Hero) ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.08),
                    colorScheme.primary.withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15), width: 0.5),
              ),
              child: Column(
                children: [
                  Text(
                    _type == 'debit' ? 'Expense' : 'Income',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountCtrl,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -2,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -2,
                        color: colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      hintText: '0',
                      hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.15)),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    validator: (v) => (v == null || double.tryParse(v) == null) ? 'Enter valid amount' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ─── Type Toggle ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _TypePill(
                  label: 'Expense', icon: Icons.south_west_rounded, selected: _type == 'debit',
                  color: AppTheme.getExpenseColor(context),
                  onTap: () => setState(() => _type = 'debit'),
                )),
                const SizedBox(width: 10),
                Expanded(child: _TypePill(
                  label: 'Income', icon: Icons.north_east_rounded, selected: _type == 'credit',
                  color: AppTheme.getIncomeColor(context),
                  onTap: () => setState(() => _type = 'credit'),
                )),
              ],
            ),
            const SizedBox(height: 20),

            // ─── Description ──────────────────────────────────────────────
            _GlassTextField(
              controller: _descCtrl,
              label: 'Description',
              hint: 'Where did you spend?',
              icon: Icons.description_rounded,
              validator: (v) => (v == null || v.isEmpty) ? 'Enter description' : null,
            ),
            const SizedBox(height: 16),

            // ─── Category ─────────────────────────────────────────────────
            _GlassDropdown(
              label: 'Category',
              value: _category,
              items: const ['Food', 'Transport', 'Shopping', 'Entertainment', 'Bills', 'Other'],
              onChanged: (v) => setState(() => _category = v ?? 'Other'),
            ),
            const SizedBox(height: 16),

            // ─── Date ─────────────────────────────────────────────────────
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDate: _date,
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04), width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat.yMMMd().format(_date),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ─── Save Button ──────────────────────────────────────────────
            GestureDetector(
              onTap: _saving ? null : _save,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 8))],
                ),
                child: Center(
                  child: _saving
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypePill({required this.label, required this.icon, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? color.withValues(alpha: 0.3) : (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? color : Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.w500, color: selected ? color : Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;

  const _GlassTextField({required this.controller, required this.label, required this.hint, required this.icon, this.validator});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04), width: 0.5),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _GlassDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final void Function(String?)? onChanged;

  const _GlassDropdown({required this.label, required this.value, required this.items, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04), width: 0.5),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.category_rounded, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../local/local_models.dart';
import '../local/local_storage.dart';
import '../services/widget_service.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator:
                    (v) =>
                        (v == null || double.tryParse(v) == null)
                            ? 'Enter valid amount'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                validator:
                    (v) =>
                        (v == null || v.isEmpty) ? 'Enter description' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'Food', child: Text('Food')),
                  DropdownMenuItem(
                    value: 'Transport',
                    child: Text('Transport'),
                  ),
                  DropdownMenuItem(value: 'Shopping', child: Text('Shopping')),
                  DropdownMenuItem(
                    value: 'Entertainment',
                    child: Text('Entertainment'),
                  ),
                  DropdownMenuItem(value: 'Bills', child: Text('Bills')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _category = v ?? 'Other'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date: ${_date.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: _date,
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: const Text('Pick'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'debit',
                    label: Text('Debit'),
                    icon: Icon(Icons.south_east),
                  ),
                  ButtonSegment(
                    value: 'credit',
                    label: Text('Credit'),
                    icon: Icon(Icons.north_west),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child:
                    _saving
                        ? const CircularProgressIndicator()
                        : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

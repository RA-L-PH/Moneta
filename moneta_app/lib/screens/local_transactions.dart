import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../local/local_storage.dart';
import '../local/local_models.dart';
import '../services/sms_capture.dart';

class LocalTransactionsScreen extends StatefulWidget {
  const LocalTransactionsScreen({super.key});

  @override
  State<LocalTransactionsScreen> createState() =>
      _LocalTransactionsScreenState();
}

class _LocalTransactionsScreenState extends State<LocalTransactionsScreen> {
  int _days = 30;

  @override
  void initState() {
    super.initState();
    SmsCaptureService.setWindowDays(_days);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const Text('Show last:'),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('15 days'),
                selected: _days == 15,
                onSelected: (v) {
                  if (!v) return;
                  setState(() => _days = 15);
                  SmsCaptureService.setWindowDays(15);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('30 days'),
                selected: _days == 30,
                onSelected: (v) {
                  if (!v) return;
                  setState(() => _days = 30);
                  SmsCaptureService.setWindowDays(30);
                },
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Clear local cache',
                onPressed: () async {
                  await LocalStorage.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.delete_sweep),
              ),
            ],
          ),
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable:
                Hive.box<LocalTxn>(LocalStorage.boxName).listenable(),
            builder: (context, Box<LocalTxn> box, _) {
              final now = DateTime.now();
              final cutoff = now.subtract(Duration(days: _days));
              final list =
                  box.values.where((t) => !t.date.isBefore(cutoff)).toList()
                    ..sort((a, b) => b.date.compareTo(a.date));
              if (list.isEmpty) {
                return const Center(child: Text('No local transactions yet'));
              }
              final nfIn = NumberFormat.decimalPattern('en_IN');
              return ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                padding: const EdgeInsets.all(10),
                itemBuilder: (context, i) {
                  final t = list[i];
                  final isCredit = t.type == 'credit';
                  final bg =
                      isCredit
                          ? Colors.green.withValues(alpha: 0.10)
                          : Colors.red.withValues(alpha: 0.10);
                  final fg = isCredit ? Colors.green[800] : Colors.red[800];
                  return Container(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (fg ?? Colors.black54).withValues(alpha: 0.25),
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isCredit ? Icons.south_west : Icons.north_east,
                          color: fg,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                (isCredit ? '+ ' : '- ') +
                                    nfIn.format(t.amount),
                                style: TextStyle(
                                  color: fg,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t.party,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (t.balance != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Balance: ${nfIn.format(t.balance!)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Chip(
                                    label: Text(t.category),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () async {
                                      await _editCategory(context, box, t);
                                    },
                                    child: const Text('EDIT CATEGORY'),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  Future<void> _editCategory(
    BuildContext context,
    Box<LocalTxn> box,
    LocalTxn t,
  ) async {
    final controller = TextEditingController(text: t.category);
    final res = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit category'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Enter category'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text('SAVE'),
              ),
            ],
          ),
    );
    if (res != null && res.isNotEmpty) {
      t.category = res;
      await t.save();
      setState(() {});
    }
  }
}

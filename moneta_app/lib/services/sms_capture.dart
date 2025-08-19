import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';
import '../local/local_storage.dart';
import '../local/local_models.dart';
import 'widget_service.dart';
import 'sms_parser_service.dart';
import 'notification_service.dart';

class SmsCaptureService {
  static const _channel = EventChannel('moneta/sms_stream');
  static const _inbox = MethodChannel('moneta/sms_inbox');
  static StreamSubscription? _sub;
  static bool _imported = false;
  static Duration _window = const Duration(days: 30);
  // No auth dependency in local-only mode

  static void setWindowDays(int days) {
    _window = Duration(days: days.clamp(1, 90));
  }

  static Future<void> start() async {
    if (kIsWeb || !Platform.isAndroid) return;
    // Request SMS permission
    final status = await Permission.sms.request();
    if (!status.isGranted) return;

    // Import from inbox once
    await _importInboxIfNeeded();

    _sub ??= _channel.receiveBroadcastStream().listen((event) async {
      final text = (event as String?) ?? '';
      await _maybeSend(text);
    });
  }

  static Future<void> _importInboxIfNeeded() async {
    if (_imported) return;
    try {
      final list = await _inbox.invokeMethod<List<dynamic>>('readInbox');
      if (list != null) {
        final now = DateTime.now();
        final cutoff = now.subtract(_window);
        int processedCount = 0;
        for (final item in list) {
          final map = Map<String, dynamic>.from(item as Map);
          final sender = (map['address'] as String?) ?? '';
          final body = (map['body'] as String?) ?? '';
          final millis = int.tryParse((map['date'] as String?) ?? '');
          final dt =
              millis != null
                  ? DateTime.fromMillisecondsSinceEpoch(millis)
                  : now;
          if (dt.isBefore(cutoff)) continue; // only last N days

          final text = '$sender: $body';
          // Local classify and store
          final local = _parseLocal(text, dt);
          if (local != null) {
            await LocalStorage.upsert(local);
            processedCount++;
          }
          // No backend forwarding in local-only mode
        }

        // Show notification if any transactions were processed
        if (processedCount > 0) {
          await NotificationService.showSmsProcessedNotification(
            transactionCount: processedCount,
          );
        }
      }
    } catch (_) {}
    _imported = true;
    // Update homescreen widget with fresh totals after import
    await WidgetService.updateTodayTotals();
  }

  static Future<void> _maybeSend(String text, {bool storeLocal = true}) async {
    if (text.isEmpty) return;
    final lower = text.toLowerCase();
    final looksLikeTxn =
        (lower.contains('debit') ||
            lower.contains('credited') ||
            lower.contains('credit') ||
            lower.contains('spent')) &&
        RegExp(
          r'\b[rs₹$€£]?[\s]*[0-9]+(?:,[0-9]{3})*(?:\.[0-9]{1,2})?\b',
        ).hasMatch(text);
    if (!looksLikeTxn) return;
    // Local store for live SMS too
    if (storeLocal) {
      final local = _parseLocal(text, DateTime.now());
      if (local != null) {
        await LocalStorage.upsert(local);

        // Show notification for new transaction
        await NotificationService.showTransactionNotification(
          type: local.type,
          amount: local.amount,
          party: local.party,
          balance: local.balance,
        );
      }
    }
    // Update widget totals after local store
    await WidgetService.updateTodayTotals();
  }

  // Enhanced parser using SmsParserService
  static LocalTxn? _parseLocal(String text, DateTime date) {
    // Use the enhanced SMS parser service
    final parsed = SmsParserService.categorizeTransaction(text);
    if (parsed == null) return null;

    return LocalTxn(
      amount: parsed.amount,
      type: parsed.type,
      party: parsed.recipient,
      date: date,
      balance: parsed.balance,
      category: parsed.category,
      raw: text,
    );
  }

  static Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }
}

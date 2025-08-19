import 'package:flutter/services.dart';

class NotificationService {
  static const _platform = MethodChannel('moneta/notifications');
  static bool _initialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await _platform.invokeMethod('initialize');
      _initialized = true;
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  /// Show notification for new transaction
  static Future<void> showTransactionNotification({
    required String type,
    required double amount,
    required String party,
    double? balance,
  }) async {
    try {
      await initialize();

      final isCredit = type == 'credit';
      final title = isCredit ? '💰 Money Credited' : '💸 Money Debited';

      final amountText =
          isCredit
              ? '+₹${amount.toStringAsFixed(2)}'
              : '-₹${amount.toStringAsFixed(2)}';

      String body = '$amountText';
      if (party.isNotEmpty) {
        body += ' • $party';
      }
      if (balance != null) {
        body += '\nBalance: ₹${balance.toStringAsFixed(2)}';
      }

      await _platform.invokeMethod('showNotification', {
        'id': DateTime.now().millisecondsSinceEpoch.remainder(100000),
        'title': title,
        'body': body,
        'channelId': 'moneta_transactions',
        'importance': 'default',
      });
    } catch (e) {
      // Silently fail if notifications are not available
      print('Failed to show notification: $e');
    }
  }

  /// Show notification for new SMS message entry
  static Future<void> showSmsProcessedNotification({
    required int transactionCount,
  }) async {
    try {
      await initialize();

      await _platform.invokeMethod('showNotification', {
        'id': DateTime.now().millisecondsSinceEpoch.remainder(100000) + 1,
        'title': '📱 SMS Processed',
        'body':
            'Found $transactionCount new transaction${transactionCount == 1 ? '' : 's'}',
        'channelId': 'moneta_sms',
        'importance': 'low',
      });
    } catch (e) {
      print('Failed to show SMS notification: $e');
    }
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    try {
      await initialize();
      final result = await _platform.invokeMethod('requestPermissions');
      return result == true;
    } catch (e) {
      print('Failed to request notification permissions: $e');
      return false;
    }
  }
}

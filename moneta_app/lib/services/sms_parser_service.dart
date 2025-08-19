import '../models/transaction.dart';

/// Enhanced SMS Transaction Parser Service
/// Based on the example pattern for BCCB transaction messages
class SmsParserService {
  // Known businesses and their categories for classification
  static const Map<String, String> _knownBusinesses = {
    'STAR B': 'Food & Beverages',
    'STARBUCKS': 'Food & Beverages',
    'MCDONALDS': 'Food & Beverages',
    'KFC': 'Food & Beverages',
    'PIZZA HUT': 'Food & Beverages',
    'DOMINOS': 'Food & Beverages',
    'SWIGGY': 'Food & Beverages',
    'ZOMATO': 'Food & Beverages',
    'UBER EATS': 'Food & Beverages',

    'AMAZON': 'Shopping',
    'AMZN': 'Shopping',
    'FLIPKART': 'Shopping',
    'MYNTRA': 'Shopping',
    'BIGBASKET': 'Shopping',
    'GROFERS': 'Shopping',

    'NETFLIX': 'Entertainment',
    'SPOTIFY': 'Entertainment',
    'PRIME VIDEO': 'Entertainment',
    'YOUTUBE': 'Entertainment',
    'HOTSTAR': 'Entertainment',
    'SONY LIV': 'Entertainment',

    'UBER': 'Transport',
    'OLA': 'Transport',
    'RAPIDO': 'Transport',
    'METRO': 'Transport',
    'PETROL': 'Transport',
    'FUEL': 'Transport',
    'SHELL': 'Transport',
    'BPCL': 'Transport',
    'HPCL': 'Transport',
    'IOC': 'Transport',

    'ELECTRICITY': 'Bills & Utilities',
    'WATER': 'Bills & Utilities',
    'GAS': 'Bills & Utilities',
    'INTERNET': 'Bills & Utilities',
    'MOBILE': 'Bills & Utilities',
    'RECHARGE': 'Bills & Utilities',
    'BROADBAND': 'Bills & Utilities',
    'DTH': 'Bills & Utilities',

    'HOSPITAL': 'Healthcare',
    'PHARMACY': 'Healthcare',
    'CLINIC': 'Healthcare',
    'APOLLO': 'Healthcare',
    'FORTIS': 'Healthcare',
    'MAX HEALTHCARE': 'Healthcare',

    'ATM': 'Cash Withdrawal',
    'CASH': 'Cash Withdrawal',
    'WITHDRAWAL': 'Cash Withdrawal',

    'SALARY': 'Income',
    'DIVIDEND': 'Income',
    'INTEREST': 'Income',
    'REFUND': 'Income',
    'CASHBACK': 'Income',
  };

  /// Main function to categorize SMS transaction text
  /// Returns a parsed transaction object with type, amount, recipient, category, etc.
  static ParsedTransaction? categorizeTransaction(String smsText) {
    if (smsText.isEmpty) return null;

    ParsedTransaction transaction = ParsedTransaction();

    // Step 1: Determine transaction type (Debit or Credit)
    final lowerText = smsText.toLowerCase();
    if (_isDebitTransaction(lowerText)) {
      transaction.type = 'debit';
    } else if (_isCreditTransaction(lowerText)) {
      transaction.type = 'credit';
    } else {
      // If unclear, default to debit for most SMS notifications
      transaction.type = 'debit';
    }

    // Step 2: Extract Amount
    transaction.amount = _extractAmount(smsText);
    if (transaction.amount == 0)
      return null; // Invalid transaction without amount

    // Step 3: Extract Date
    transaction.date = _extractDate(smsText);

    // Step 4: Extract Transaction ID
    transaction.transactionId = _extractTransactionId(smsText);

    // Step 5: Extract Recipient/Organization Name
    transaction.recipient = _extractRecipient(smsText);

    // Step 6: Extract Balance
    transaction.balance = _extractBalance(smsText);

    // Step 7: Classify category based on recipient name
    transaction.category = _classifyCategory(transaction.recipient);

    // Step 8: Set description
    transaction.description = _generateDescription(transaction);

    return transaction;
  }

  /// Check if transaction is a debit
  static bool _isDebitTransaction(String lowerText) {
    final debitKeywords = [
      'debited',
      'spent',
      'paid',
      'deducted',
      'withdrawn',
      'purchase',
      'payment',
      'transfer',
      'sent',
    ];
    return debitKeywords.any((keyword) => lowerText.contains(keyword));
  }

  /// Check if transaction is a credit
  static bool _isCreditTransaction(String lowerText) {
    final creditKeywords = [
      'credited',
      'received',
      'deposited',
      'refund',
      'cashback',
      'salary',
      'interest',
      'dividend',
    ];
    return creditKeywords.any((keyword) => lowerText.contains(keyword));
  }

  /// Extract amount from SMS text
  static double _extractAmount(String smsText) {
    // Pattern to match INR amounts: INR 60.00, Rs. 1,234.50, ₹ 500, etc.
    final amountPatterns = [
      RegExp(r'INR\s*(\d+(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'Rs\.?\s*(\d+(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(r'₹\s*(\d+(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false),
      RegExp(
        r'amount\s*(?:of\s*)?(?:INR|Rs\.?|₹)?\s*(\d+(?:,\d{3})*(?:\.\d{2})?)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in amountPatterns) {
      final match = pattern.firstMatch(smsText);
      if (match != null && match.group(1) != null) {
        final amountStr = match.group(1)!.replaceAll(',', '');
        return double.tryParse(amountStr) ?? 0.0;
      }
    }

    return 0.0;
  }

  /// Extract date from SMS text
  static String _extractDate(String smsText) {
    // Pattern to match dates like: 17-AUG-2025, 17-08-2025, 17/08/2025
    final datePatterns = [
      RegExp(r'On\s+(\d{2}-[A-Z]{3}-\d{4})', caseSensitive: false),
      RegExp(r'(\d{2}-\d{2}-\d{4})'),
      RegExp(r'(\d{2}/\d{2}/\d{4})'),
      RegExp(r'(\d{1,2}\s+[A-Z]{3}\s+\d{4})', caseSensitive: false),
    ];

    for (final pattern in datePatterns) {
      final match = pattern.firstMatch(smsText);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }

    // If no date found, return current date
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-${_getMonthAbbr(now.month)}-${now.year}';
  }

  /// Extract transaction ID from SMS text
  static String _extractTransactionId(String smsText) {
    // Pattern to match transaction IDs like: UPI/DR/522916825224, REF123456, etc.
    final idPatterns = [
      RegExp(r'UPI/(?:DR|CR)/(\d+)', caseSensitive: false),
      RegExp(r'REF\s*(?:NO\.?\s*)?(\w+)', caseSensitive: false),
      RegExp(r'TXN\s*(?:ID\s*)?(\w+)', caseSensitive: false),
      RegExp(r'TRANSACTION\s*(?:ID\s*)?(\w+)', caseSensitive: false),
    ];

    for (final pattern in idPatterns) {
      final match = pattern.firstMatch(smsText);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }

    return '';
  }

  /// Extract recipient/merchant name from SMS text
  static String _extractRecipient(String smsText) {
    // Pattern to match recipients after UPI transaction IDs - most specific first
    final recipientPatterns = [
      RegExp(r'by\s+UPI/(?:DR|CR)/\d+/([A-Z\s&.-]+?)\.', caseSensitive: false),
      RegExp(r'for\s+UPI/(?:DR|CR)/\d+/([A-Z\s&.-]+?)\.', caseSensitive: false),
      RegExp(
        r'at\s+([A-Z][A-Z\s&.-]*?)(?:\s+for|\s+on|\.|$)',
        caseSensitive: false,
      ),
      RegExp(
        r'to\s+([A-Z][A-Z\s&.-]*?)(?:\s+on|\s+at|\s+for|\.|$)',
        caseSensitive: false,
      ),
      RegExp(
        r'from\s+([A-Z][A-Z\s&.-]*?)(?:\s+on|\s+at|\s+for|\.|$)',
        caseSensitive: false,
      ),
      RegExp(
        r'for\s+([A-Z][A-Z\s&.-]*?)(?:\s+from|\s+on|\s+at|\.|$)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in recipientPatterns) {
      final match = pattern.firstMatch(smsText);
      if (match != null && match.group(1) != null) {
        final recipient = match.group(1)!.trim();
        // Clean up common suffixes and bank names
        final cleaned =
            recipient
                .replaceAll(RegExp(r'\s+for$', caseSensitive: false), '')
                .replaceAll(RegExp(r'\s+on$', caseSensitive: false), '')
                .replaceAll(RegExp(r'\s+at$', caseSensitive: false), '')
                .replaceAll(RegExp(r'\s+online.*$', caseSensitive: false), '')
                .replaceAll(RegExp(r'\s+purchase.*$', caseSensitive: false), '')
                .trim();
        if (cleaned.isNotEmpty && cleaned.length > 1) {
          return cleaned;
        }
      }
    }

    // Special handling for UPI patterns that include the recipient in a specific format
    final upiMatch = RegExp(
      r'UPI/(?:DR|CR)/\d+/([^.\s]+)',
      caseSensitive: false,
    ).firstMatch(smsText);
    if (upiMatch != null && upiMatch.group(1) != null) {
      return upiMatch.group(1)!.trim();
    }

    // Look for SALARY, CASHBACK, REFUND etc.
    final specialRecipients = [
      'SALARY',
      'CASHBACK',
      'REFUND',
      'DIVIDEND',
      'INTEREST',
    ];
    for (final special in specialRecipients) {
      if (smsText.toUpperCase().contains(special)) {
        return special;
      }
    }

    return 'Unknown';
  }

  /// Extract available balance from SMS text
  static double? _extractBalance(String smsText) {
    // Pattern to match balance with Indian number formatting (1,50,893.38)
    final balancePatterns = [
      RegExp(
        r'(?:Clear|Avl|Available)\s+bal(?:ance)?\s+(?:INR|Rs\.?|₹)?\s*(\d{1,2}(?:,\d{2})*,\d{3}(?:\.\d{2})?)',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:Clear|Avl|Available)\s+bal(?:ance)?\s+(?:INR|Rs\.?|₹)?\s*(\d+(?:,\d{3})*(?:\.\d{2})?)',
        caseSensitive: false,
      ),
      RegExp(
        r'Bal(?:ance)?:?\s+(?:INR|Rs\.?|₹)?\s*(\d{1,2}(?:,\d{2})*,\d{3}(?:\.\d{2})?)',
        caseSensitive: false,
      ),
      RegExp(
        r'Bal(?:ance)?:?\s+(?:INR|Rs\.?|₹)?\s*(\d+(?:,\d{3})*(?:\.\d{2})?)',
        caseSensitive: false,
      ),
    ];

    for (final pattern in balancePatterns) {
      final match = pattern.firstMatch(smsText);
      if (match != null && match.group(1) != null) {
        final balanceStr = match.group(1)!.replaceAll(',', '');
        return double.tryParse(balanceStr);
      }
    }

    return null;
  }

  /// Classify transaction category based on recipient name
  static String _classifyCategory(String recipient) {
    final upperRecipient = recipient.toUpperCase();

    // Direct match
    if (_knownBusinesses.containsKey(upperRecipient)) {
      return _knownBusinesses[upperRecipient]!;
    }

    // Partial match
    for (final business in _knownBusinesses.keys) {
      if (upperRecipient.contains(business) ||
          business.contains(upperRecipient)) {
        return _knownBusinesses[business]!;
      }
    }

    // Keyword-based classification
    final lowerRecipient = recipient.toLowerCase();

    if (_containsAny(lowerRecipient, [
      'restaurant',
      'cafe',
      'food',
      'kitchen',
      'dining',
    ])) {
      return 'Food & Beverages';
    }

    if (_containsAny(lowerRecipient, [
      'shop',
      'store',
      'mall',
      'market',
      'retail',
    ])) {
      return 'Shopping';
    }

    if (_containsAny(lowerRecipient, [
      'hospital',
      'clinic',
      'medical',
      'pharmacy',
      'doctor',
    ])) {
      return 'Healthcare';
    }

    if (_containsAny(lowerRecipient, [
      'school',
      'college',
      'university',
      'education',
      'course',
    ])) {
      return 'Education';
    }

    if (_containsAny(lowerRecipient, [
      'bank',
      'atm',
      'loan',
      'emi',
      'finance',
    ])) {
      return 'Banking & Finance';
    }

    return 'Other';
  }

  /// Generate a description for the transaction
  static String _generateDescription(ParsedTransaction transaction) {
    final type = transaction.type == 'debit' ? 'Payment' : 'Received';
    final recipient =
        transaction.recipient.isNotEmpty ? transaction.recipient : 'Unknown';
    return '$type to $recipient';
  }

  /// Helper method to check if text contains any of the given keywords
  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  /// Get month abbreviation
  static String _getMonthAbbr(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }
}

/// Parsed transaction model
class ParsedTransaction {
  String type = '';
  double amount = 0.0;
  String date = '';
  String recipient = '';
  String category = '';
  String transactionId = '';
  double? balance;
  String description = '';

  ParsedTransaction();

  @override
  String toString() {
    return '''
ParsedTransaction {
  type: $type,
  amount: $amount,
  date: $date,
  recipient: $recipient,
  category: $category,
  transactionId: $transactionId,
  balance: $balance,
  description: $description
}''';
  }

  /// Convert to TransactionModel
  TransactionModel toTransactionModel() {
    return TransactionModel(
      id:
          transactionId.isNotEmpty
              ? transactionId
              : DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      description: description,
      category: category,
      date: _parseDate(date),
      type: type,
    );
  }

  /// Parse date string to DateTime
  DateTime _parseDate(String dateStr) {
    try {
      // Handle different date formats
      if (dateStr.contains('-') && dateStr.length >= 10) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = _parseMonth(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
      }
    } catch (e) {
      // If parsing fails, return current date
    }
    return DateTime.now();
  }

  /// Parse month from string (JAN, FEB, etc. or 01, 02, etc.)
  int _parseMonth(String monthStr) {
    const monthMap = {
      'JAN': 1,
      'FEB': 2,
      'MAR': 3,
      'APR': 4,
      'MAY': 5,
      'JUN': 6,
      'JUL': 7,
      'AUG': 8,
      'SEP': 9,
      'OCT': 10,
      'NOV': 11,
      'DEC': 12,
    };

    final upperMonth = monthStr.toUpperCase();
    if (monthMap.containsKey(upperMonth)) {
      return monthMap[upperMonth]!;
    }

    // Try parsing as number
    return int.tryParse(monthStr) ?? DateTime.now().month;
  }
}

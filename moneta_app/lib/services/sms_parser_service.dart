import '../models/transaction.dart';

/// Deterministic Tokenization Pipeline for Indian Bank SMS Parsing.
/// 
/// Architecture:
/// Step 1: Clean & Normalize
/// Step 2: Flow Classification (DEBIT/CREDIT/OTP/BILL_REMINDER)
/// Step 3: Instrument Extraction (UPI/CREDIT_CARD/DEBIT_CARD/ATM/BANK_TRANSFER/CHEQUE)
/// Step 4: Numeric Token Pull (Amount, Account, Balance)
/// Step 5: Structured Output
class SmsParserService {
  // ─── Authorized Bank Sender IDs (TRAI format: XX-XXXXXX) ─────────────────
  static const List<String> _bankSenderIds = [
    'HDFCBK', 'HDFC', 'SBI', 'SBIBP', 'ICICIB', 'ICICI',
    'AXISBK', 'AXIS', 'KOTAK', 'KVB', 'YESBANK', 'YESBK',
    'PNBSMS', 'PNB', 'BOBSMS', 'BOB', 'CANBNK', 'CANARA',
    'UNIBNK', 'UBI', 'IDBIBK', 'IDBI', 'INDUSB', 'INDUSIND',
    'FEDBK', 'FEDERAL', 'DCBBNK', 'RBLBANK', 'RBL',
    'AUBANK', 'AU', 'BANDHAN', 'JIO', 'AIRTEL',
    'PAYTM', 'PHONEPE', 'GPAY', 'CRED', 'MOBIKWIK',
  ];

  // ─── Discard Keywords (OTP, Promos) ─────────────────────────────────────
  static const List<String> _discardKeywords = [
    'otp', 'password', 'verification code', 'verify',
    'offer', 'discount', 'cashback offer', 'win',
    'congratulations', 'lucky', 'reward point',
    'click here', 'unsubscribe', 'opt out',
    't&c apply', 'terms and conditions',
  ];

  // ─── Known Businesses & Categories ───────────────────────────────────────
  static const Map<String, String> _knownBusinesses = {
    'SWIGGY': 'Food & Beverages', 'ZOMATO': 'Food & Beverages',
    'DOMINOS': 'Food & Beverages', 'PIZZAHUT': 'Food & Beverages',
    'KFC': 'Food & Beverages', 'MCDONALD': 'Food & Beverages',
    'SUBWAY': 'Food & Beverages', 'BURGER KING': 'Food & Beverages',
    'STARBUCKS': 'Food & Beverages', 'CCD': 'Food & Beverages',
    'HALDIRAM': 'Food & Beverages', 'BIGBASKET': 'Food & Beverages',
    'BLINKIT': 'Food & Beverages', 'ZEPTO': 'Food & Beverages',
    'DUNZO': 'Food & Beverages', 'DMART': 'Food & Beverages',
    'RELIANCE FRESH': 'Food & Beverages', 'JIOMART': 'Food & Beverages',
    'SPAR': 'Food & Beverages',
    'AMAZON': 'Shopping', 'AMZN': 'Shopping',
    'FLIPKART': 'Shopping', 'MYNTRA': 'Shopping',
    'AJIO': 'Shopping', 'MEESHO': 'Shopping',
    'NYKAA': 'Shopping', 'TATA CLiQ': 'Shopping',
    'CROMA': 'Shopping', 'RELIANCE DIGITAL': 'Shopping',
    'DECATHLON': 'Shopping', 'IKEA': 'Shopping',
    'APOLLO PHARMACY': 'Shopping', 'MEDPLUS': 'Shopping',
    'NETMEDS': 'Shopping', '1MG': 'Shopping',
    'NETFLIX': 'Entertainment', 'AMAZON PRIME': 'Entertainment',
    'PRIME VIDEO': 'Entertainment', 'HOTSTAR': 'Entertainment',
    'DISNEY': 'Entertainment', 'SONY LIV': 'Entertainment',
    'ZEE5': 'Entertainment', 'JIOCINEMA': 'Entertainment',
    'SPOTIFY': 'Entertainment', 'YOUTUBE': 'Entertainment',
    'YOUTUBE PREMIUM': 'Entertainment', 'BOOKMYSHOW': 'Entertainment',
    'PLAYSTORE': 'Entertainment', 'GOOGLE PLAY': 'Entertainment',
    'UBER': 'Transport', 'OLA': 'Transport', 'RAPIDO': 'Transport',
    'BLUE SMART': 'Transport', 'SREdbus': 'Transport',
    'REDCBUS': 'Transport', 'KSRTC': 'Transport',
    'DMRC': 'Transport', 'Zoomcar': 'Transport',
    'SHELL': 'Transport', 'BPCL': 'Transport',
    'HPCL': 'Transport', 'IOC': 'Transport',
    'BSES': 'Bills & Utilities', 'TATA POWER': 'Bills & Utilities',
    'KSEB': 'Bills & Utilities', 'BSNL': 'Bills & Utilities',
    'AIRTEL': 'Bills & Utilities', 'JIO': 'Bills & Utilities',
    'VI': 'Bills & Utilities', 'VODAFONE': 'Bills & Utilities',
    'IDEA': 'Bills & Utilities', 'TATASKY': 'Bills & Utilities',
    'DISH TV': 'Bills & Utilities', 'ACT FIBER': 'Bills & Utilities',
    'HATHWAY': 'Bills & Utilities',
    'APOLLO': 'Healthcare', 'FORTIS': 'Healthcare',
    'MAX HEALTHCARE': 'Healthcare', 'AIIMS': 'Healthcare',
    'NARAYANA': 'Healthcare', 'MANIPAL': 'Healthcare',
    'DR LAL PATH': 'Healthcare', 'METROPOLIS': 'Healthcare',
    'BYJU': 'Education', 'UNACADEMY': 'Education',
    'VEDANTU': 'Education', 'UDEMY': 'Education',
    'COURSERA': 'Education', 'NPTEL': 'Education',
    'ATM': 'Cash Withdrawal', 'LOAN': 'Banking & Finance',
    'EMI': 'Banking & Finance', 'LIC': 'Insurance',
    'HDFC LIFE': 'Insurance', 'ICICI PRU': 'Insurance',
    'SBI LIFE': 'Insurance', 'TATA AIA': 'Insurance',
    'BAJAJ ALLIANZ': 'Insurance',
    'SALARY': 'Income', 'DIVIDEND': 'Income',
    'INTEREST': 'Income', 'REFUND': 'Income',
    'CASHBACK': 'Income', 'BONUS': 'Income',
    'PENSION': 'Income', 'FREELANCE': 'Income',
    'MAKEMYTRIP': 'Travel', 'GOIBIBO': 'Travel',
    'YATRA': 'Travel', 'CLEARTRIP': 'Travel',
    'AIRBNB': 'Travel', 'OYO': 'Travel',
    'HILTON': 'Travel', 'MARRIOTT': 'Travel',
    'GROCERY': 'Groceries', 'KIRANA': 'Groceries',
  };

  // ─── Investment Keywords ─────────────────────────────────────────────────
  static const List<String> _investmentKeywords = [
    'dividend', 'bonus shares', 'stock dividend', 'int div',
    'mutual fund', 'sip installment', 'lumpsum',
    'zerodha', 'upstox', 'angel one', 'groww', 'dhan', 'fyers',
    'icici direct', 'sharekhan', 'kotak sec', 'motilal',
    'nsdl', 'cdsl', 'dp id',
    'itc', 'tata', 'reliance', 'hdfc', 'infosys', 'wipro',
    'sbin', 'ongc', 'coal india', 'hal', 'adani',
    'bajaj', 'asian paint', 'maruti', 'titan', 'ultracemco',
    'broker', 'demat', 'trading', 'equity',
  ];

  // ─── Custom Categories (user-configurable) ───────────────────────────────
  static final Map<String, String> _customCategories = {};

  static void registerCustomCategories(Map<String, String> mappings) {
    _customCategories.addAll(mappings.map((k, v) => MapEntry(k.toUpperCase(), v)));
  }

  static void clearCustomCategories() => _customCategories.clear();

  static List<String> get availableCategories => [
    'Food & Beverages', 'Shopping', 'Entertainment', 'Transport',
    'Bills & Utilities', 'Healthcare', 'Education', 'Banking & Finance',
    'Cash Withdrawal', 'Transfer', 'Income', 'Investment',
    'Subscriptions', 'Rent', 'Travel', 'Groceries', 'Insurance',
    'Other',
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN PARSE ENTRY - Deterministic Tokenization Pipeline
  // ═══════════════════════════════════════════════════════════════════════════

  static ParsedTransaction? categorizeTransaction(String smsText) {
    if (smsText.trim().isEmpty) return null;
    final trimmed = smsText.trim();

    // ── Step 0: Sender Validation ───────────────────────────────────────
    if (!_isBankSender(trimmed) && !_looksLikeTransaction(trimmed.toLowerCase())) return null;

    // ── Step 1: Clean & Normalize ───────────────────────────────────────
    final cleanText = _normalize(trimmed);

    // ── Step 2: Discard OTPs / Promos ───────────────────────────────────
    if (_shouldDiscard(cleanText)) return null;

    // ── Step 3: Flow Classification ─────────────────────────────────────
    final flowType = _classifyFlow(cleanText);
    if (flowType == 'UNKNOWN') return null;

    // ── Step 4: Instrument Extraction ───────────────────────────────────
    final instrument = _extractInstrument(cleanText);

    // ── Step 5: Numeric Token Pull ──────────────────────────────────────
    final allAmounts = _extractAllAmounts(cleanText);
    if (allAmounts.isEmpty) return null;

    final accountMask = _extractAccountMask(cleanText);
    final balance = _extractBalance(cleanText, flowType, allAmounts);
    final reference = _extractReference(cleanText, instrument);
    final date = _extractDate(cleanText);
    final recipient = _extractRecipient(cleanText);

    // ── Step 6: Allocate Values ─────────────────────────────────────────
    double amount;
    if (flowType == 'OTP') {
      amount = allAmounts.isNotEmpty ? allAmounts[0] : 0;
    } else if (flowType == 'BILL_REMINDER') {
      amount = allAmounts[0];
    } else {
      amount = allAmounts[0];
    }

    if (amount <= 0) return null;

    // ── Step 7: Build Result ────────────────────────────────────────────
    final t = ParsedTransaction();
    t.type = flowType == 'CREDIT' ? 'credit' : 'debit';
    t.amount = amount;
    t.date = date;
    t.recipient = recipient;
    t.accountNumber = accountMask;
    t.balance = balance;
    t.transactionId = reference;
    t.bank = _detectBank(trimmed);
    t.accountType = instrument;
    t.category = _classifyCategory(recipient, trimmed);
    t.description = _generateDescription(t, instrument, flowType);
    t.confidence = _computeConfidence(t);

    return t;
  }

  static List<ParsedTransaction> parseBatch(List<String> messages) {
    final results = <ParsedTransaction>[];
    for (final msg in messages) {
      final parsed = categorizeTransaction(msg);
      if (parsed != null && !_isDuplicate(results, parsed)) {
        results.add(parsed);
      }
    }
    results.sort((a, b) => b.parsedDate.compareTo(a.parsedDate));
    return results;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 1: Clean & Normalize
  // ═══════════════════════════════════════════════════════════════════════════

  static String _normalize(String sms) {
    var text = sms;
    // Remove excessive whitespace and linebreaks
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Standardize all currency symbols to ₹ for display
    text = text.replaceAll(RegExp(r'INR', caseSensitive: false), '₹');
    text = text.replaceAll(RegExp(r'Rs\.?'), '₹');
    return text;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 2: Sender ID Validation
  // ═══════════════════════════════════════════════════════════════════════════

  static bool _isBankSender(String sms) {
    final upper = sms.toUpperCase();
    return _bankSenderIds.any((id) => upper.contains(id));
  }

  static bool _shouldDiscard(String lower) {
    if (RegExp(r'\b\d{4,8}\b.*\botp\b').hasMatch(lower) ||
        lower.contains('one time password') ||
        lower.contains('verification code')) {
      return true;
    }
    return _discardKeywords.any((kw) => lower.contains(kw));
  }

  static bool _looksLikeTransaction(String lower) {
    final hasAmount = lower.contains('₹') || lower.contains('rs') ||
        RegExp(r'\d+[,.]?\d*').hasMatch(lower);
    final hasAction = lower.contains('debited') || lower.contains('credited') ||
        lower.contains('spent') || lower.contains('paid') ||
        lower.contains('received') || lower.contains('transferred') ||
        lower.contains('withdrawn') || lower.contains('deposited') ||
        lower.contains('purchase') || lower.contains('payment') ||
        lower.contains('sent') || lower.contains('balance') ||
        lower.contains('upi/dr') || lower.contains('upi/cr');
    return hasAmount && hasAction;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 3: Flow Classification
  // ═══════════════════════════════════════════════════════════════════════════

  static String _classifyFlow(String cleanText) {
    final lower = cleanText.toLowerCase();

    // Check for declined/failed transactions first
    if (RegExp(r'(?:declined|failed|reversed|cancelled|error|insufficient)').hasMatch(lower)) {
      return 'UNKNOWN';
    }

    // DEBIT: debited, withdrawn, spent, charged, deducted, transferred
    if (RegExp(r'(?:debited|withdrawn|spent|charged|deducted|transferred|paid|sent)').hasMatch(lower)) {
      return 'DEBIT';
    }

    // CREDIT: credited, deposited, received, added
    if (RegExp(r'(?:credited|deposited|received|added|reversed)').hasMatch(lower)) {
      return 'CREDIT';
    }

    // OTP: verification tokens
    if (RegExp(r'(?:OTP|One Time Password|Verification Code|secret code)').hasMatch(lower)) {
      return 'OTP';
    }

    // BILL_REMINDER: due dates, minimum due
    if (RegExp(r'(?:Total Due|Minimum Due|Payment Due Date|statement generated)').hasMatch(lower)) {
      return 'BILL_REMINDER';
    }

    return 'UNKNOWN';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 4: Instrument Extraction
  // ═══════════════════════════════════════════════════════════════════════════

  static String _extractInstrument(String cleanText) {
    final lower = cleanText.toLowerCase();

    // UPI
    if (RegExp(r'(?:UPI|VPA|@upi|@oksbi|@paytm|@ybl|@axl|@okhdfcbank|@okicici|@oksbi)').hasMatch(lower)) {
      return 'UPI';
    }

    // Credit Card
    if (RegExp(r'(?:Credit Card|spent on Card|CC ending|credit card ending)').hasMatch(lower)) {
      return 'Credit Card';
    }

    // Debit Card
    if (RegExp(r'(?:Debit Card|DC ending|debit card ending|via Debit Card)').hasMatch(lower)) {
      return 'Debit Card';
    }

    // ATM
    if (RegExp(r'(?:ATM|Wdl|Cash withdrawal|withdrawn from ATM)').hasMatch(lower)) {
      return 'ATM';
    }

    // Bank Transfer (NEFT/RTGS/IMPS)
    if (RegExp(r'(?:NEFT|RTGS|UTR|IMPS)').hasMatch(lower)) {
      return 'Bank Transfer';
    }

    // Cheque
    if (RegExp(r'(?:Cheque No|Chq|clearing to|Chq paid)').hasMatch(lower)) {
      return 'Cheque';
    }

    // Wallet
    if (RegExp(r'(?:Wallet|Paytm|PhonePe|GPay|Amazon Pay)').hasMatch(lower)) {
      return 'Wallet';
    }

    return 'Bank Account';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 5: Numeric Token Pull
  // ═══════════════════════════════════════════════════════════════════════════

  static List<double> _extractAllAmounts(String cleanText) {
    final amounts = <double>[];
    final regex = RegExp(r'₹\s*([\d,]+\.?\d*)', caseSensitive: false);
    for (final match in regex.allMatches(cleanText)) {
      final val = double.tryParse(match.group(1)!.replaceAll(',', ''));
      if (val != null && val > 0) amounts.add(val);
    }
    return amounts;
  }

  static String _extractAccountMask(String cleanText) {
    // A/c XX1234, A/c XXXXXX, Card ending 1234
    final patterns = [
      RegExp(r'(?:A/c|Acct|Account)\s*([x*.-]*\d{3,4})\b', caseSensitive: false),
      RegExp(r'(?:Card|Crd|ending)\s*(\d{3,4})\b', caseSensitive: false),
      RegExp(r'(?:A/c|Acct)\s*(XXXXXX|XX\d{4}|\*+\d{4})', caseSensitive: false),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(cleanText);
      if (m?.group(1) != null) return m!.group(1)!;
    }
    return '';
  }

  static double? _extractBalance(String cleanText, String flowType, List<double> allAmounts) {
    final lower = cleanText.toLowerCase();

    // Credit card: "Available Limit: Rs. XX" or "Limit Avbl: Rs. XX"
    if (flowType == 'BILL_REMINDER' || RegExp(r'(?:Credit Card|CC ending)').hasMatch(lower)) {
      if (allAmounts.length > 1) return allAmounts[1];
    }

    // Balance keywords: "Bal: ₹XX", "Avl Bal: ₹XX", "Balance: ₹XX"
    final balMatch = RegExp(
      r'(?:Bal|Balance|Avl Bal|Available Balance|Net Bal|Updated Wallet Bal)\s*:?\s*₹\s*([\d,]+\.?\d*)',
      caseSensitive: false,
    ).firstMatch(cleanText);
    if (balMatch != null) {
      return double.tryParse(balMatch.group(1)!.replaceAll(',', ''));
    }

    // Fallback: second amount is balance
    if (allAmounts.length > 1 && flowType != 'OTP') {
      return allAmounts[1];
    }

    return null;
  }

  static String _extractReference(String cleanText, String instrument) {
    // UPI RRN (12-digit)
    if (instrument == 'UPI') {
      final rrnMatch = RegExp(r'(?:Ref|RRN|UPI)\s*(?:No\.?\s*)?(\d{12})', caseSensitive: false).firstMatch(cleanText);
      if (rrnMatch != null) return rrnMatch.group(1)!;
    }

    // NEFT/RTGS UTR (alphanumeric)
    if (instrument == 'Bank Transfer') {
      final utrMatch = RegExp(r'(?:UTR|NEFT|RTGS)\s*(?:No\.?\s*)?([A-Z]{4}[A-Z0-9]{8,18})', caseSensitive: false).firstMatch(cleanText);
      if (utrMatch != null) return utrMatch.group(1)!.toUpperCase();
    }

    // Generic reference
    final refMatch = RegExp(
      r'(?:Ref|UTR|RRN|TXN|REFNO|Ref No)\s*(?:No\.?\s*)?([A-Za-z0-9]{6,})',
      caseSensitive: false,
    ).firstMatch(cleanText);
    if (refMatch != null) return refMatch.group(1)!.trim();

    return '';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATE EXTRACTION
  // ═══════════════════════════════════════════════════════════════════════════

  static String _extractDate(String sms) {
    // Pattern 1: "15-08-26" or "15-08-2026" or "15/08/26"
    final ddMmYy = RegExp(r'(\d{1,2})[-.](\d{1,2})[-.](\d{2,4})').firstMatch(sms);
    if (ddMmYy != null) {
      final day = ddMmYy.group(1)!.padLeft(2, '0');
      final month = ddMmYy.group(2)!.padLeft(2, '0');
      var year = ddMmYy.group(3)!;
      if (year.length == 2) {
        final yr = int.tryParse(year) ?? 0;
        year = yr <= 50 ? '20$year' : '19$year';
      }
      return '$day-$month-$year';
    }

    // Pattern 2: "17-AUG-2025"
    final dmyAbbr = RegExp(r'(\d{1,2})[-.\/]([A-Za-z]{3})[-.\/](\d{4})').firstMatch(sms);
    if (dmyAbbr != null) {
      final month = _parseMonth(dmyAbbr.group(2)!);
      if (month != null) {
        return '${dmyAbbr.group(1)!.padLeft(2, '0')}-${dmyAbbr.group(2)!.toUpperCase()}-${dmyAbbr.group(3)}';
      }
    }

    // Pattern 3: "17 Aug 2025"
    final dMonthYyyy = RegExp(r'(\d{1,2})\s+([A-Za-z]{3,9})\s+(\d{4})').firstMatch(sms);
    if (dMonthYyyy != null) {
      final month = _parseMonth(dMonthYyyy.group(2)!);
      if (month != null) {
        return '${dMonthYyyy.group(1)!.padLeft(2, '0')}-${dMonthYyyy.group(2)!.toUpperCase()}-${dMonthYyyy.group(3)}';
      }
    }

    // Pattern 4: "Aug 17, 2025"
    final monthDY = RegExp(r'([A-Za-z]{3,9})\s+(\d{1,2}),?\s+(\d{4})').firstMatch(sms);
    if (monthDY != null) {
      final month = _parseMonth(monthDY.group(1)!);
      if (month != null) {
        return '${monthDY.group(2)!.padLeft(2, '0')}-${monthDY.group(1)!.toUpperCase()}-${monthDY.group(3)}';
      }
    }

    // Pattern 5: ISO "2025-08-17"
    final isoMatch = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(sms);
    if (isoMatch != null) {
      return '${isoMatch.group(3)}-${isoMatch.group(2)}-${isoMatch.group(1)}';
    }

    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-${_monthAbbr(now.month)}-${now.year}';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RECIPIENT / MERCHANT EXTRACTION
  // ═══════════════════════════════════════════════════════════════════════════

  static String _extractRecipient(String sms) {
    final upper = sms.toUpperCase();

    // UPI path: UPI/DR/1234/MERCHANT or UPI/CR/1234/SENDER
    final upiPath = RegExp(
      r'UPI/(?:DR|CR)/\d+/([A-Za-z][A-Za-z0-9 &.\-]{1,40}?)(?:\s|\.|,|$)',
    ).firstMatch(upper);
    if (upiPath?.group(1) != null) {
      return _cleanRecipient(upiPath!.group(1)!);
    }

    // Prepositions: "at/to/from MERCHANT"
    final preps = [
      RegExp(r'\bat\s+([A-Z][A-Z0-9 &.\-]{1,40}?)(?:\s+(?:for|on|via|\.|,|$))', caseSensitive: false),
      RegExp(r'\bto\s+([A-Z][A-Z0-9 &.\-]{1,40}?)(?:\s+(?:on|at|for|\.|,|$))', caseSensitive: false),
      RegExp(r'\bfrom\s+([A-Z][A-Z0-9 &.\-]{1,40}?)(?:\s+(?:on|at|for|\.|,|$))', caseSensitive: false),
    ];
    for (final p in preps) {
      final m = p.firstMatch(sms);
      if (m?.group(1) != null) {
        final cleaned = _cleanRecipient(m!.group(1)!);
        if (cleaned.length > 1) return cleaned;
      }
    }

    // "for SALARY CREDIT"
    final forMatch = RegExp(r'for\s+([A-Z][A-Z &]{2,30}?)(?:\s+(?:from|on|\.|,|$))').firstMatch(upper);
    if (forMatch?.group(1) != null) {
      final cleaned = _cleanRecipient(forMatch!.group(1)!);
      if (cleaned.length > 1) return cleaned;
    }

    const specials = [
      'SALARY', 'CASHBACK', 'REFUND', 'DIVIDEND', 'INTEREST',
      'BONUS', 'REIMBURSEMENT', 'COMMISSION',
    ];
    for (final s in specials) {
      if (upper.contains(s)) return s;
    }

    return 'Unknown';
  }

  static String _cleanRecipient(String raw) {
    var s = raw.trim();
    s = s.replaceAll(RegExp(r'\s*(for|on|at|via|through|online|purchase|payment|transaction)\s*$', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'[.,;:]+$'), '');
    s = s.replaceAll(RegExp(r'\s+'), ' ');
    return s.trim();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BANK DETECTION
  // ═══════════════════════════════════════════════════════════════════════════

  static String _detectBank(String sms) {
    const banks = {
      'HDFC': [r'HDFC'], 'SBI': [r'SBI', r'STATE\s*BANK'],
      'ICICI': [r'ICICI'], 'Axis': [r'Axis', r'AXIS'],
      'Kotak': [r'Kotak', r'KOTAK'], 'PNB': [r'PNB'],
      'BOI': [r'BOI', r'BANK\s*OF\s*INDIA'], 'IDBI': [r'IDBI'],
      'IndusInd': [r'IndusInd'], 'BOB': [r'BOB', r'BANK\s*OF\s*BARODA'],
      'Canara': [r'CANARA'], 'UBI': [r'UNION\s*BANK', r'UBI'],
      'Federal': [r'FEDERAL'], 'RBL': [r'RBL'],
      'AU': [r'AU\s*BANK'], 'Bandhan': [r'BANDHAN'],
    };
    final upper = sms.toUpperCase();
    for (final entry in banks.entries) {
      for (final p in entry.value) {
        if (RegExp(p, caseSensitive: false).hasMatch(upper)) return entry.key;
      }
    }
    return 'Unknown';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORY CLASSIFICATION
  // ═══════════════════════════════════════════════════════════════════════════

  static String _classifyCategory(String recipient, String fullSms) {
    final upper = recipient.toUpperCase();

    for (final entry in _customCategories.entries) {
      if (upper.contains(entry.key) || entry.key.contains(upper)) return entry.value;
    }

    if (_knownBusinesses.containsKey(upper)) return _knownBusinesses[upper]!;

    for (final entry in _knownBusinesses.entries) {
      if (upper.contains(entry.key) || entry.key.contains(upper)) return entry.value;
    }

    final lowerSms = fullSms.toLowerCase();
    if (_investmentKeywords.any((kw) => lowerSms.contains(kw))) return 'Investment';

    if (_containsAny(lowerSms, ['neft', 'rtgs', 'imps', 'upi/dr', 'upi/cr', 'transferred to', 'sent to', 'received from'])) {
      return 'Transfer';
    }

    final lr = recipient.toLowerCase();
    if (_containsAny(lr, ['restaurant', 'cafe', 'food', 'swiggy', 'zomato'])) return 'Food & Beverages';
    if (_containsAny(lr, ['grocery', 'kirana', 'supermarket', 'mart'])) return 'Groceries';
    if (_containsAny(lr, ['shop', 'store', 'mall', 'retail'])) return 'Shopping';
    if (_containsAny(lr, ['hospital', 'clinic', 'medical', 'pharmacy'])) return 'Healthcare';
    if (_containsAny(lr, ['school', 'college', 'university', 'course'])) return 'Education';
    if (_containsAny(lr, ['petrol', 'diesel', 'fuel'])) return 'Transport';
    if (_containsAny(lr, ['electricity', 'power', 'water', 'internet', 'recharge'])) return 'Bills & Utilities';
    if (_containsAny(lr, ['bank', 'atm', 'loan', 'emi'])) return 'Banking & Finance';
    if (_containsAny(lr, ['insurance', 'lic', 'policy'])) return 'Insurance';
    if (_containsAny(lr, ['rent', 'maintenance', 'society'])) return 'Rent';
    if (_containsAny(lr, ['hotel', 'flight', 'airline', 'train', 'travel'])) return 'Travel';

    if (_containsAny(lowerSms, ['salary', 'dividend', 'interest earned', 'bonus', 'pension'])) return 'Income';

    return 'Other';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONFIDENCE SCORE
  // ═══════════════════════════════════════════════════════════════════════════

  static double _computeConfidence(ParsedTransaction t) {
    double score = 25;
    if (t.date.isNotEmpty && !t.date.contains(_monthAbbr(DateTime.now().month))) {
      score += 20;
    } else if (t.date.isNotEmpty) {
      score += 5;
    }
    if (t.transactionId.isNotEmpty) score += 15;
    if (t.recipient.isNotEmpty && t.recipient != 'Unknown') score += 15;
    if (t.accountNumber.isNotEmpty) score += 5;
    if (t.balance != null) score += 10;
    if (t.category != 'Other') score += 10;
    if (t.bank != 'Unknown') score += 5;
    return score.clamp(0, 100);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEDUPLICATION
  // ═══════════════════════════════════════════════════════════════════════════

  static bool _isDuplicate(List<ParsedTransaction> existing, ParsedTransaction candidate) {
    for (final e in existing) {
      if (e.amount == candidate.amount &&
          e.type == candidate.type &&
          e.recipient.toLowerCase() == candidate.recipient.toLowerCase() &&
          e.parsedDate.difference(candidate.parsedDate).abs().inMinutes <= 5) {
        return true;
      }
    }
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DESCRIPTION
  // ═══════════════════════════════════════════════════════════════════════════

  static String _generateDescription(ParsedTransaction t, String instrument, String flowType) {
    if (flowType == 'OTP') return 'OTP Verification';
    if (flowType == 'BILL_REMINDER') return 'Bill Reminder';

    final typeLabel = t.type == 'credit' ? 'Received' : 'Paid';
    final who = (t.recipient.isNotEmpty && t.recipient != 'Unknown') ? t.recipient : '';
    final via = instrument.isNotEmpty ? ' via $instrument' : '';
    return who.isNotEmpty ? '$typeLabel to$who$via' : '$typeLabel$via';
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  static bool _containsAny(String text, List<String> keywords) =>
      keywords.any((kw) => text.contains(kw));

  static String _monthAbbr(int month) {
    const m = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return m[(month - 1).clamp(0, 11)];
  }

  static int? _parseMonth(String s) {
    const map = {
      'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
      'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12,
      'JANUARY': 1, 'FEBRUARY': 2, 'MARCH': 3, 'APRIL': 4,
      'JUNE': 6, 'JULY': 7, 'AUGUST': 8, 'SEPTEMBER': 9,
      'OCTOBER': 10, 'NOVEMBER': 11, 'DECEMBER': 12,
    };
    return map[s.toUpperCase()] ?? int.tryParse(s);
  }
}

// ─── Models ────────────────────────────────────────────────────────────────

class ParsedTransaction {
  String type = '';
  double amount = 0.0;
  String date = '';
  String recipient = '';
  String category = '';
  String transactionId = '';
  String accountNumber = '';
  String accountType = '';
  double? balance;
  String description = '';
  String bank = '';
  double confidence = 0;

  ParsedTransaction();

  DateTime get parsedDate {
    try {
      if (RegExp(r'\d{1,2}-[A-Za-z]{3}-\d{4}').hasMatch(date)) {
        final p = date.split('-');
        return DateTime(int.parse(p[2]), _parseMonth(p[1]), int.parse(p[0]));
      }
      if (RegExp(r'\d{1,2}[/-]\d{1,2}[/-]\d{4}').hasMatch(date)) {
        final m = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{4})').firstMatch(date)!;
        return DateTime(int.parse(m.group(3)!), int.parse(m.group(2)!), int.parse(m.group(1)!));
      }
      if (RegExp(r'\d{4}-\d{2}-\d{2}').hasMatch(date)) return DateTime.parse(date);
      if (RegExp(r'\d{1,2}\s+[A-Za-z]{3}\s+\d{4}').hasMatch(date)) {
        final p = date.split(RegExp(r'\s+'));
        return DateTime(int.parse(p[2]), _parseMonth(p[1]), int.parse(p[0]));
      }
    } catch (_) {}
    return DateTime.now();
  }

  int _parseMonth(String s) {
    const map = {
      'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
      'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12,
    };
    return map[s.toUpperCase()] ?? int.tryParse(s) ?? DateTime.now().month;
  }

  @override
  String toString() =>
      'ParsedTransaction{type=$type, amt=$amount, date=$date, recipient=$recipient, cat=$category}';

  TransactionModel toTransactionModel() {
    return TransactionModel(
      id: transactionId.isNotEmpty
          ? transactionId
          : DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      description: description,
      category: category,
      date: parsedDate,
      type: type,
    );
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:moneta_app/services/sms_parser_service.dart';

void main() {
  group('SMS Parser – Core Parsing', () {
    test('should parse BCCB debit transaction correctly', () {
      const sms =
          "Your BCCB A/c XXXXXX is debited INR 60.00 On 17-AUG-2025 by UPI/DR/522916825224/STAR B. Clear bal INR 1,50,893.38.";

      final r = SmsParserService.categorizeTransaction(sms);

      expect(r, isNotNull);
      expect(r!.type, 'debit');
      expect(r.amount, 60.0);
      expect(r.date, '17-AUG-2025');
      expect(r.transactionId, '522916825224');
      expect(r.recipient, 'STAR B');
      expect(r.category, 'Food & Beverages');
      expect(r.balance, 150893.38);
      expect(r.bank, 'BCCB');
      expect(r.confidence, greaterThan(70));
    });

    test('should parse credit transaction correctly', () {
      const sms =
          "Your HDFC Bank A/c XX1234 is credited INR 5,000.00 on 18-AUG-2025 for SALARY CREDIT. Avl bal INR 45,678.90.";

      final r = SmsParserService.categorizeTransaction(sms);

      expect(r, isNotNull);
      expect(r!.type, 'credit');
      expect(r.amount, 5000.0);
      expect(r.date, '18-AUG-2025');
      expect(r.recipient, contains('SALARY'));
      expect(r.category, 'Income');
      expect(r.balance, 45678.90);
      expect(r.bank, 'HDFC');
    });

    test('should parse Amazon transaction correctly', () {
      const sms =
          "ICICI Bank: Rs 1,250.50 debited from A/c XX5678 on 19-AUG-2025 at AMAZON for online purchase. Bal: Rs 23,456.78";

      final r = SmsParserService.categorizeTransaction(sms);

      expect(r, isNotNull);
      expect(r!.type, 'debit');
      expect(r.amount, 1250.5);
      expect(r.date, '19-AUG-2025');
      expect(r.recipient, 'AMAZON');
      expect(r.category, 'Shopping');
      expect(r.balance, 23456.78);
      expect(r.bank, 'ICICI');
    });

    test('should parse Uber transaction correctly', () {
      const sms =
          "Axis Bank: A/c XX7890 debited INR 75.00 on 22-AUG-2025 for UPI/DR/456789123/UBER. Clear bal INR 8,765.43";

      final r = SmsParserService.categorizeTransaction(sms);

      expect(r, isNotNull);
      expect(r!.type, 'debit');
      expect(r.amount, 75.0);
      expect(r.date, '22-AUG-2025');
      expect(r.transactionId, '456789123');
      expect(r.recipient, 'UBER');
      expect(r.category, 'Transport');
      expect(r.balance, 8765.43);
      expect(r.bank, 'Axis');
    });

    test('should handle Netflix cashback correctly', () {
      const sms =
          "PNB: Your A/c is credited Rs 850.00 on 23-AUG-2025 for CASHBACK from NETFLIX. Avl bal Rs 12,543.21";

      final r = SmsParserService.categorizeTransaction(sms);

      expect(r, isNotNull);
      expect(r!.type, 'credit');
      expect(r.amount, 850.0);
      expect(r.recipient, contains('NETFLIX'));
      expect(r.category, 'Entertainment');
      expect(r.bank, 'PNB');
    });

    test('should handle unknown merchant as Other', () {
      const sms =
          "Bank: Rs 500.00 debited from A/c XX1234 on 20-AUG-2025 at UNKNOWN MERCHANT. Bal: Rs 10,000.00";

      final r = SmsParserService.categorizeTransaction(sms);

      expect(r, isNotNull);
      expect(r!.type, 'debit');
      expect(r.amount, 500.0);
      expect(r.recipient, 'UNKNOWN MERCHANT');
      expect(r.category, 'Other');
    });

    test('should return null for empty SMS', () {
      expect(SmsParserService.categorizeTransaction(''), isNull);
    });

    test('should return null for blank SMS', () {
      expect(SmsParserService.categorizeTransaction('   '), isNull);
    });

    test('should return null for non-transaction SMS', () {
      expect(SmsParserService.categorizeTransaction('Hello, how are you?'), isNull);
    });

    test('should return null for SMS with no amount', () {
      expect(
        SmsParserService.categorizeTransaction('Your account was debited today'),
        isNull,
      );
    });
  });

  group('SMS Parser – Bank Detection', () {
    test('should detect SBI', () {
      const sms =
          "SBI: Your A/c XX1234 is debited Rs 1,000.00 on 01-JAN-2026. Bal: Rs 50,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.bank, 'SBI');
    });

    test('should detect Kotak', () {
      const sms =
          "Kotak Bank: A/c XX5678 debited INR 2,500.00 on 15-MAR-2026 for UPI/DR/9999/MERCHANT. Bal INR 12,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.bank, 'Kotak');
    });

    test('should detect Yes Bank', () {
      const sms =
          "YES BANK: Rs 750.00 debited from A/c XX9999 on 10-FEB-2026. Bal: Rs 8,500.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.bank, 'Yes Bank');
    });

    test('should detect Bank of Baroda', () {
      const sms =
          "Bank of Baroda: A/c XX1111 credited INR 10,000.00 on 05-APR-2026. Bal INR 45,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.bank, 'Bank of Baroda');
    });

    test('should detect Canara Bank', () {
      const sms =
          "Canara Bank: Rs 200.00 debited on 12-MAY-2026. Bal Rs 5,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.bank, 'Canara Bank');
    });

    test('should detect Union Bank', () {
      const sms =
          "Union Bank: A/c XX2222 debited INR 3,000.00 on 20-JUN-2026. Bal INR 15,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.bank, 'Union Bank');
    });

    test('should detect IDBI', () {
      const sms =
          "IDBI Bank: Rs 1,500.00 debited from A/c on 08-JUL-2026. Bal Rs 20,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.bank, 'IDBI');
    });

    test('should detect IndusInd', () {
      const sms =
          "IndusInd Bank: A/c debited INR 800.00 on 01-AUG-2026. Bal INR 3,200.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.bank, 'IndusInd');
    });

    test('should detect Federal Bank', () {
      const sms =
          "Federal Bank: Rs 450.00 debited on 14-SEP-2026. Bal Rs 7,800.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.bank, 'Federal Bank');
    });
  });

  group('SMS Parser – Date Formats', () {
    test('should parse DD-MMM-YYYY format', () {
      const sms =
          "Bank: Rs 100.00 debited on 17-AUG-2025. Bal Rs 1,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.date, '17-AUG-2025');
    });

    test('should parse DD/MM/YYYY format', () {
      const sms =
          "Bank: Rs 100.00 debited on 17/08/2025. Bal Rs 1,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.date, '17/08/2025');
    });

    test('should parse YYYY-MM-DD ISO format', () {
      const sms =
          "Bank: Rs 100.00 debited on 2025-08-17. Bal Rs 1,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.date, '2025-08-17');
    });

    test('should parse "17 Aug 2025" format', () {
      const sms =
          "Bank: Rs 100.00 debited on 17 Aug 2025. Bal Rs 1,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.date, '17 Aug 2025');
    });

    test('should default to current date when no date found', () {
      const sms =
          "Bank: Rs 100.00 debited. Bal Rs 1,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r, isNotNull);
      expect(r!.date, isNotEmpty);
    });
  });

  group('SMS Parser – UPI Patterns', () {
    test('should extract recipient from UPI/DR path', () {
      const sms =
          "SBI: Rs 250.00 debited on 01-JAN-2026 by UPI/DR/12345678/SWIGGY. Bal Rs 5,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.recipient, 'SWIGGY');
      expect(r.transactionId, '12345678');
    });

    test('should extract recipient from "for UPI/CR" pattern', () {
      const sms =
          "HDFC Bank: Rs 10,000.00 credited on 15-JAN-2026 for UPI/CR/87654321/SALARY. Bal Rs 50,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.type, 'credit');
      expect(r.recipient, contains('SALARY'));
    });

    test('should handle UPI with long merchant name', () {
      const sms =
          "Axis: Rs 150.00 debited on 01-JAN-2026 by UPI/DR/11111111/RELIANCE FRESH. Bal Rs 8,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.recipient, 'RELIANCE FRESH');
      expect(r.category, 'Food & Beverages');
    });
  });

  group('SMS Parser – Category Classification', () {
    test('should classify Swiggy as Food & Beverages', () {
      const sms =
          "SBI: Rs 450.00 debited on 20-AUG-2025 by UPI/DR/789012345/SWIGGY. Bal Rs 15,678.90";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.category, 'Food & Beverages');
    });

    test('should classify Uber as Transport', () {
      const sms =
          "Bank: Rs 200.00 debited on 01-JAN-2026 at UBER. Bal Rs 5,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.category, 'Transport');
    });

    test('should classify Netflix as Entertainment', () {
      const sms =
          "Bank: Rs 649.00 debited on 01-JAN-2026 at NETFLIX. Bal Rs 10,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.category, 'Entertainment');
    });

    test('should classify Amazon as Shopping', () {
      const sms =
          "Bank: Rs 2,000.00 debited on 01-JAN-2026 at AMAZON. Bal Rs 15,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.category, 'Shopping');
    });

    test('should classify hospital visit as Healthcare', () {
      const sms =
          "Bank: Rs 5,000.00 debited on 01-JAN-2026 at APOLLO HOSPITAL. Bal Rs 20,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.category, 'Healthcare');
    });

    test('should classify BYJU as Education', () {
      const sms =
          "Bank: Rs 3,000.00 debited on 01-JAN-2026 at BYJU. Bal Rs 12,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.category, 'Education');
    });

    test('should classify petrol pump as Transport', () {
      const sms =
          "Bank: Rs 2,000.00 debited on 01-JAN-2026 at HPCL PETROL. Bal Rs 18,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.category, 'Transport');
    });

    test('should classify electricity as Bills & Utilities', () {
      const sms =
          "Bank: Rs 1,500.00 debited on 01-JAN-2026 for ELECTRICITY BILL. Bal Rs 10,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.category, 'Bills & Utilities');
    });

    test('should classify hotel as Travel', () {
      const sms =
          "Bank: Rs 8,000.00 debited on 01-JAN-2026 at OYO HOTEL. Bal Rs 25,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.category, 'Travel');
    });

    test('should classify ATM withdrawal as Cash Withdrawal', () {
      const sms =
          "Bank: Rs 10,000.00 debited on 01-JAN-2026 at ATM WITHDRAWAL. Bal Rs 40,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.category, 'Cash Withdrawal');
    });
  });

  group('SMS Parser – Edge Cases', () {
    test('should handle amount without decimals', () {
      const sms =
          "Bank: Rs 500 debited on 01-JAN-2026. Bal Rs 5,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.amount, 500.0);
    });

    test('should handle very large amounts', () {
      const sms =
          "Bank: INR 9,99,999.99 debited on 01-JAN-2026. Bal INR 10,00,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.amount, 999999.99);
      expect(r.balance, 1000000.00);
    });

    test('should handle very small amounts', () {
      const sms =
          "Bank: Rs 0.50 debited on 01-JAN-2026. Bal Rs 1,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.amount, 0.50);
    });

    test('should handle SMS without balance', () {
      const sms =
          "Bank: Rs 100.00 debited on 01-JAN-2026 for UPI/DR/123456/MERCHANT.";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r, isNotNull);
      expect(r!.balance, isNull);
    });

    test('should handle SMS without transaction ID', () {
      const sms =
          "Bank: Rs 100.00 debited on 01-JAN-2026 at AMAZON. Bal Rs 5,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r, isNotNull);
      expect(r!.transactionId, isEmpty);
    });

    test('should handle multiple amount patterns (pick first)', () {
      const sms =
          "Bank: Account XX1234 has INR 100.00 and INR 200.00. Debited Rs 100.00. Bal Rs 5,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r, isNotNull);
      expect(r!.amount, greaterThan(0));
    });

    test('should compute confidence score', () {
      const sms =
          "HDFC Bank: A/c XX1234 debited INR 1,500.00 on 15-MAR-2026 by UPI/DR/999999/SWIGGY. Clear bal INR 25,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.confidence, greaterThan(80));
    });

    test('should have low confidence for minimal SMS', () {
      const sms =
          "Bank: Rs 100 debited. Bal Rs 500.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.confidence, lessThan(70));
    });
  });

  group('SMS Parser – Batch Parsing', () {
    test('should parse multiple SMS and skip invalid', () {
      final messages = [
        "SBI: Rs 100.00 debited on 01-JAN-2026 at SWIGGY. Bal Rs 5,000.00",
        "Hello, how are you?",
        "HDFC: Rs 200.00 credited on 02-JAN-2026 for SALARY. Bal Rs 50,000.00",
        "",
        "ICICI: Rs 50.00 debited on 03-JAN-2026 at UBER. Bal Rs 10,000.00",
      ];

      final results = SmsParserService.parseBatch(messages);

      expect(results.length, 3);
      // Should be sorted by date descending
      expect(results[0].amount, 50.0); // 03-JAN
      expect(results[1].amount, 200.0); // 02-JAN
      expect(results[2].amount, 100.0); // 01-JAN
    });

    test('should deduplicate similar transactions', () {
      final messages = [
        "SBI: Rs 100.00 debited on 01-JAN-2026 at SWIGGY. Bal Rs 5,000.00",
        "SBI: Rs 100.00 debited on 01-JAN-2026 at SWIGGY. Bal Rs 5,000.00",
      ];

      final results = SmsParserService.parseBatch(messages);
      expect(results.length, 1);
    });

    test('should return empty list for all invalid SMS', () {
      final messages = ["Hello", "How are you?", "Good morning"];
      final results = SmsParserService.parseBatch(messages);
      expect(results, isEmpty);
    });
  });

  group('SMS Parser – Custom Categories', () {
    tearDown(() {
      SmsParserService.clearCustomCategories();
    });

    test('should use custom category when registered', () {
      SmsParserService.registerCustomCategories({
        'MYSHOP': 'My Custom Category',
      });

      const sms =
          "Bank: Rs 500.00 debited on 01-JAN-2026 at MYSHOP. Bal Rs 10,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.category, 'My Custom Category');
    });

    test('should clear custom categories', () {
      SmsParserService.registerCustomCategories({'MYSHOP': 'Custom'});
      SmsParserService.clearCustomCategories();

      const sms =
          "Bank: Rs 500.00 debited on 01-JAN-2026 at MYSHOP. Bal Rs 10,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.category, isNot('Custom'));
    });
  });

  group('SMS Parser – Available Categories', () {
    test('should expose available categories list', () {
      final cats = SmsParserService.availableCategories;
      expect(cats, contains('Food & Beverages'));
      expect(cats, contains('Shopping'));
      expect(cats, contains('Transport'));
      expect(cats, contains('Entertainment'));
      expect(cats, contains('Healthcare'));
      expect(cats, contains('Education'));
      expect(cats, contains('Travel'));
      expect(cats, contains('Groceries'));
      expect(cats, contains('Insurance'));
      expect(cats, contains('Rent'));
      expect(cats, contains('Subscriptions'));
      expect(cats, contains('Other'));
    });
  });

  group('SMS Parser – ParsedTransaction Model', () {
    test('should parse date correctly', () {
      const sms =
          "Bank: Rs 100.00 debited on 17-AUG-2025. Bal Rs 1,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      final parsedDate = r!.parsedDate;
      expect(parsedDate.year, 2025);
      expect(parsedDate.month, 8);
      expect(parsedDate.day, 17);
    });

    test('should convert to TransactionModel', () {
      const sms =
          "SBI: Rs 500.00 debited on 15-MAR-2026 by UPI/DR/123456/SWIGGY. Bal Rs 10,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      final model = r!.toTransactionModel();

      expect(model.amount, 500.0);
      expect(model.type, 'debit');
      expect(model.category, 'Food & Beverages');
      expect(model.id, '123456');
      expect(model.description, contains('SWIGGY'));
    });

    test('should generate description', () {
      const sms =
          "Bank: Rs 100.00 debited on 01-JAN-2026 at AMAZON. Bal Rs 5,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.description, contains('Paid'));
      expect(r.description, contains('AMAZON'));
    });
  });

  group('SMS Parser – Indian Number Formatting', () {
    test('should parse Indian comma grouping for amount', () {
      const sms =
          "Bank: INR 1,50,893.38 debited on 01-JAN-2026. Bal INR 2,00,000.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.amount, 150893.38);
    });

    test('should parse Indian comma grouping for balance', () {
      const sms =
          "Bank: Rs 100.00 debited on 01-JAN-2026. Bal Rs 5,43,210.00";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.balance, 543210.00);
    });

    test('should parse standard comma grouping', () {
      const sms =
          "Bank: Rs 1,234.56 debited on 01-JAN-2026. Bal Rs 9,876.54";
      final r = SmsParserService.categorizeTransaction(sms);
      expect(r!.amount, 1234.56);
      expect(r.balance, 9876.54);
    });
  });
}

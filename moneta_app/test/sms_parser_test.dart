import 'package:flutter_test/flutter_test.dart';
import 'package:moneta_app/services/sms_parser_service.dart';

void main() {
  group('SMS Parser Service Tests', () {
    test('should parse BCCB debit transaction correctly', () {
      const smsText =
          "Your BCCB A/c XXXXXX is debited INR 60.00 On 17-AUG-2025 by UPI/DR/522916825224/STAR B. Clear bal INR 1,50,893.38.";

      final result = SmsParserService.categorizeTransaction(smsText);

      expect(result, isNotNull);
      expect(result!.type, equals('debit'));
      expect(result.amount, equals(60.0));
      expect(result.date, equals('17-AUG-2025'));
      expect(result.transactionId, equals('522916825224'));
      expect(result.recipient, equals('STAR B'));
      expect(result.category, equals('Food & Beverages'));
      expect(result.balance, equals(150893.38));
    });

    test('should parse credit transaction correctly', () {
      const smsText =
          "Your HDFC Bank A/c XX1234 is credited INR 5,000.00 on 18-AUG-2025 for SALARY CREDIT. Avl bal INR 45,678.90.";

      final result = SmsParserService.categorizeTransaction(smsText);

      expect(result, isNotNull);
      expect(result!.type, equals('credit'));
      expect(result.amount, equals(5000.0));
      expect(result.date, equals('18-AUG-2025'));
      expect(result.recipient, contains('SALARY'));
      expect(result.category, equals('Income'));
      expect(result.balance, equals(45678.90));
    });

    test('should parse Amazon transaction correctly', () {
      const smsText =
          "ICICI Bank: Rs 1,250.50 debited from A/c XX5678 on 19-AUG-2025 at AMAZON for online purchase. Bal: Rs 23,456.78";

      final result = SmsParserService.categorizeTransaction(smsText);

      expect(result, isNotNull);
      expect(result!.type, equals('debit'));
      expect(result.amount, equals(1250.5));
      expect(result.date, equals('19-AUG-2025'));
      expect(result.recipient, equals('AMAZON'));
      expect(result.category, equals('Shopping'));
      expect(result.balance, equals(23456.78));
    });

    test('should parse Uber transaction correctly', () {
      const smsText =
          "Axis Bank: A/c XX7890 debited INR 75.00 on 22-AUG-2025 for UPI/DR/456789123/UBER. Clear bal INR 8,765.43";

      final result = SmsParserService.categorizeTransaction(smsText);

      expect(result, isNotNull);
      expect(result!.type, equals('debit'));
      expect(result.amount, equals(75.0));
      expect(result.date, equals('22-AUG-2025'));
      expect(result.transactionId, equals('456789123'));
      expect(result.recipient, equals('UBER'));
      expect(result.category, equals('Transport'));
      expect(result.balance, equals(8765.43));
    });

    test('should handle Netflix transaction correctly', () {
      const smsText =
          "PNB: Your A/c is credited Rs 850.00 on 23-AUG-2025 for CASHBACK from NETFLIX. Avl bal Rs 12,543.21";

      final result = SmsParserService.categorizeTransaction(smsText);

      expect(result, isNotNull);
      expect(result!.type, equals('credit'));
      expect(result.amount, equals(850.0));
      expect(result.date, equals('23-AUG-2025'));
      expect(result.recipient, contains('NETFLIX'));
      expect(result.category, equals('Entertainment'));
      expect(result.balance, equals(12543.21));
    });

    test('should handle unknown merchant correctly', () {
      const smsText =
          "Bank: Rs 500.00 debited from A/c XX1234 on 20-AUG-2025 at UNKNOWN MERCHANT. Bal: Rs 10,000.00";

      final result = SmsParserService.categorizeTransaction(smsText);

      expect(result, isNotNull);
      expect(result!.type, equals('debit'));
      expect(result.amount, equals(500.0));
      expect(result.recipient, equals('UNKNOWN MERCHANT'));
      expect(result.category, equals('Other'));
    });

    test('should return null for invalid SMS', () {
      const smsText = "This is not a banking SMS";

      final result = SmsParserService.categorizeTransaction(smsText);

      expect(result, isNull);
    });

    test('should return null for empty SMS', () {
      const smsText = "";

      final result = SmsParserService.categorizeTransaction(smsText);

      expect(result, isNull);
    });

    test('should handle Swiggy food delivery correctly', () {
      const smsText =
          "SBI: Your A/c XX9012 is debited Rs 450.00 on 20-AUG-2025 by UPI/DR/789012345/SWIGGY. Available balance Rs 15,678.90";

      final result = SmsParserService.categorizeTransaction(smsText);

      expect(result, isNotNull);
      expect(result!.type, equals('debit'));
      expect(result.amount, equals(450.0));
      expect(result.transactionId, equals('789012345'));
      expect(result.recipient, equals('SWIGGY'));
      expect(result.category, equals('Food & Beverages'));
    });
  });
}

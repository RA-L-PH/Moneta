import 'package:flutter/material.dart';
import '../services/sms_parser_service.dart';

class SmsParserTestScreen extends StatefulWidget {
  const SmsParserTestScreen({Key? key}) : super(key: key);

  @override
  State<SmsParserTestScreen> createState() => _SmsParserTestScreenState();
}

class _SmsParserTestScreenState extends State<SmsParserTestScreen> {
  final TextEditingController _smsController = TextEditingController();
  ParsedTransaction? _parsedResult;

  // Sample SMS messages for testing
  final List<String> _sampleMessages = [
    "Your BCCB A/c XXXXXX is debited INR 60.00 On 17-AUG-2025 by UPI/DR/522916825224/STAR B. Clear bal INR 1,50,893.38.",
    "Your HDFC Bank A/c XX1234 is credited INR 5,000.00 on 18-AUG-2025 for SALARY CREDIT. Avl bal INR 45,678.90.",
    "ICICI Bank: Rs 1,250.50 debited from A/c XX5678 on 19-AUG-2025 at AMAZON for online purchase. Bal: Rs 23,456.78",
    "SBI: Your A/c XX9012 is debited Rs 450.00 on 20-AUG-2025 by UPI/DR/789012345/SWIGGY. Available balance Rs 15,678.90",
    "BOI: Rs 2,500.00 credited to A/c XX3456 on 21-AUG-2025 for REFUND from FLIPKART. Balance Rs 18,345.67",
    "Axis Bank: A/c XX7890 debited INR 75.00 on 22-AUG-2025 for UPI/DR/456789123/UBER. Clear bal INR 8,765.43",
    "PNB: Your A/c is credited Rs 850.00 on 23-AUG-2025 for CASHBACK from NETFLIX. Avl bal Rs 12,543.21",
  ];

  void _parseSms() {
    final text = _smsController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _parsedResult = SmsParserService.categorizeTransaction(text);
      });
    }
  }

  void _loadSampleMessage(String message) {
    _smsController.text = message;
    _parseSms();
  }

  void _clearAll() {
    setState(() {
      _smsController.clear();
      _parsedResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Parser Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sample Messages Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sample SMS Messages',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_sampleMessages.length, (index) {
                      final message = _sampleMessages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () => _loadSampleMessage(message),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              message,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter SMS Text to Parse',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _smsController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Paste your banking SMS here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _parseSms,
                          child: const Text('Parse SMS'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: _clearAll,
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results Section
            if (_parsedResult != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parsed Result',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _buildResultRow('Type', _parsedResult!.type),
                      _buildResultRow(
                        'Amount',
                        '₹${_parsedResult!.amount.toStringAsFixed(2)}',
                      ),
                      _buildResultRow('Date', _parsedResult!.date),
                      _buildResultRow('Recipient', _parsedResult!.recipient),
                      _buildResultRow('Category', _parsedResult!.category),
                      _buildResultRow(
                        'Transaction ID',
                        _parsedResult!.transactionId.isNotEmpty
                            ? _parsedResult!.transactionId
                            : 'Not found',
                      ),
                      _buildResultRow(
                        'Balance',
                        _parsedResult!.balance != null
                            ? '₹${_parsedResult!.balance!.toStringAsFixed(2)}'
                            : 'Not found',
                      ),
                      _buildResultRow(
                        'Description',
                        _parsedResult!.description,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Transaction Model Preview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction Model',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          _parsedResult!.toTransactionModel().toString(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontFamily: 'monospace'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: value == 'Not found' ? Colors.grey : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _smsController.dispose();
    super.dispose();
  }
}

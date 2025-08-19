class TransactionModel {
  final String id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final String type; // 'debit' | 'credit'

  TransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.type,
  });
}

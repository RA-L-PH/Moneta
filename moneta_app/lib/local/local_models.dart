import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class LocalTxn extends HiveObject {
  @HiveField(0)
  double amount;
  @HiveField(1)
  String type; // 'debit' | 'credit'
  @HiveField(2)
  String party; // org/individual text
  @HiveField(3)
  DateTime date;
  @HiveField(4)
  double? balance;
  @HiveField(5)
  String category;
  @HiveField(6)
  String raw;

  LocalTxn({
    required this.amount,
    required this.type,
    required this.party,
    required this.date,
    this.balance,
    this.category = 'Other',
    required this.raw,
  });
}

@HiveType(typeId: 2)
class MonthlyReport extends HiveObject {
  @HiveField(0)
  int year;
  @HiveField(1)
  int month;
  @HiveField(2)
  double totalIncome;
  @HiveField(3)
  double totalExpense;
  @HiveField(4)
  Map<String, double> categoryBreakdown;
  @HiveField(5)
  String aiSummary;
  @HiveField(6)
  DateTime generatedAt;
  @HiveField(7)
  double? averageBalance;
  @HiveField(8)
  int transactionCount;

  MonthlyReport({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.categoryBreakdown,
    required this.aiSummary,
    required this.generatedAt,
    this.averageBalance,
    required this.transactionCount,
  });

  String get monthName {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

class LocalTxnAdapter extends TypeAdapter<LocalTxn> {
  @override
  final int typeId = 1;

  @override
  LocalTxn read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return LocalTxn(
      amount: (fields[0] as num).toDouble(),
      type: fields[1] as String,
      party: fields[2] as String,
      date: fields[3] as DateTime,
      balance: (fields[4] as num?)?.toDouble(),
      category: (fields[5] as String?) ?? 'Other',
      raw: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LocalTxn obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.party)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.balance)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.raw);
  }
}

class MonthlyReportAdapter extends TypeAdapter<MonthlyReport> {
  @override
  final int typeId = 2;

  @override
  MonthlyReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return MonthlyReport(
      year: fields[0] as int,
      month: fields[1] as int,
      totalIncome: (fields[2] as num).toDouble(),
      totalExpense: (fields[3] as num).toDouble(),
      categoryBreakdown: Map<String, double>.from(fields[4] as Map),
      aiSummary: fields[5] as String,
      generatedAt: fields[6] as DateTime,
      averageBalance: (fields[7] as num?)?.toDouble(),
      transactionCount: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyReport obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.year)
      ..writeByte(1)
      ..write(obj.month)
      ..writeByte(2)
      ..write(obj.totalIncome)
      ..writeByte(3)
      ..write(obj.totalExpense)
      ..writeByte(4)
      ..write(obj.categoryBreakdown)
      ..writeByte(5)
      ..write(obj.aiSummary)
      ..writeByte(6)
      ..write(obj.generatedAt)
      ..writeByte(7)
      ..write(obj.averageBalance)
      ..writeByte(8)
      ..write(obj.transactionCount);
  }
}

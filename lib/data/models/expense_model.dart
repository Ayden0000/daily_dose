import 'package:hive/hive.dart';

part 'expense_model.g.dart';

/// Expense model for expense tracking
///
/// Stored in Hive with TypeAdapter for efficient serialization.
@HiveType(typeId: 1)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String category;

  @HiveField(3)
  String? note;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
    required this.createdAt,
  });

  /// Create a copy with updated fields
  ExpenseModel copyWith({
    String? id,
    double? amount,
    String? category,
    String? note,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Check if expense is from today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if expense is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if expense is from this month
  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  @override
  String toString() =>
      'ExpenseModel(id: $id, amount: $amount, category: $category)';
}

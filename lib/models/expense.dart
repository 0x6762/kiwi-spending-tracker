import 'account.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date; // Transaction date (just the date, no time)
  final DateTime createdAt; // For sorting same-day items
  final String? category;
  final String? notes;
  final bool isFixed; // Whether this is a fixed monthly expense
  final String accountId;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.createdAt,
    this.category,
    this.notes,
    this.isFixed = false, // Default to variable expense
    required this.accountId,
  });

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    DateTime? createdAt,
    String? category,
    String? notes,
    bool? isFixed,
    String? accountId,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      isFixed: isFixed ?? this.isFixed,
      accountId: accountId ?? this.accountId,
    );
  }

  // Convert to and from JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'category': category,
      'notes': notes,
      'isFixed': isFixed,
      'accountId': accountId,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
      category: json['category'],
      notes: json['notes'],
      isFixed: json['isFixed'] ?? false,
      accountId: json['accountId'] ?? DefaultAccounts.checking.id,
    );
  }
}

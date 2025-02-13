import 'account.dart';

enum ExpenseType {
  subscription,  // Fixed recurring (Netflix, Spotify)
  fixed,        // Variable recurring (Electricity, Water)
  variable      // Variable Variable (Groceries, Entertainment)
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date; // Transaction date (just the date, no time)
  final DateTime createdAt; // For sorting same-day items
  final String? categoryId;
  final String? notes;
  final ExpenseType type;
  final String accountId;
  
  // Type-specific fields
  final String? billingCycle; // For subscriptions (Monthly/Yearly)
  final DateTime? nextBillingDate; // For subscriptions
  final DateTime? dueDate; // For fixed expenses
  final bool? isVariableAmount; // For fixed expenses

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.createdAt,
    this.categoryId,
    this.notes,
    this.type = ExpenseType.variable,
    required this.accountId,
    this.billingCycle,
    this.nextBillingDate,
    this.dueDate,
    this.isVariableAmount,
  });

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    DateTime? createdAt,
    String? categoryId,
    String? notes,
    ExpenseType? type,
    String? accountId,
    String? billingCycle,
    DateTime? nextBillingDate,
    DateTime? dueDate,
    bool? isVariableAmount,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      accountId: accountId ?? this.accountId,
      billingCycle: billingCycle ?? this.billingCycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      dueDate: dueDate ?? this.dueDate,
      isVariableAmount: isVariableAmount ?? this.isVariableAmount,
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
      'categoryId': categoryId,
      'notes': notes,
      'type': type.index,
      'accountId': accountId,
      'billingCycle': billingCycle,
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isVariableAmount': isVariableAmount,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['createdAt']),
      categoryId: json['categoryId'],
      notes: json['notes'],
      type: ExpenseType.values[json['type'] as int],
      accountId: json['accountId'],
      billingCycle: json['billingCycle'],
      nextBillingDate: json['nextBillingDate'] != null 
          ? DateTime.parse(json['nextBillingDate'])
          : null,
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate'])
          : null,
      isVariableAmount: json['isVariableAmount'],
    );
  }
}

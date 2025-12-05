enum ExpenseFrequency {
  oneTime,
  daily,
  weekly,
  biWeekly,
  monthly,
  quarterly,
  yearly,
  custom
}

enum ExpenseStatus { pending, paid, overdue, cancelled }

enum ExpenseNecessity {
  essential, // Needs (food, housing, utilities)
  discretionary, // Wants (entertainment, dining out)
  savings // Future needs/wants
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final DateTime createdAt;
  final String? categoryId;
  final String? notes;
  final String accountId;

  final ExpenseNecessity necessity;
  final bool isRecurring;
  final ExpenseFrequency frequency;
  final ExpenseStatus status;

  final DateTime? nextBillingDate;
  final DateTime? dueDate;

  final DateTime? endDate;
  final String? budgetId;
  final String? paymentMethod;
  final List<String>? tags;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.createdAt,
    this.categoryId,
    this.notes,
    required this.accountId,
    this.nextBillingDate,
    this.dueDate,
    this.necessity = ExpenseNecessity.discretionary,
    this.isRecurring = false,
    this.frequency = ExpenseFrequency.oneTime,
    this.status = ExpenseStatus.paid,
    this.endDate,
    this.budgetId,
    this.paymentMethod,
    this.tags,
  });

  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    DateTime? createdAt,
    String? categoryId,
    String? notes,
    String? accountId,
    DateTime? nextBillingDate,
    DateTime? dueDate,
    ExpenseNecessity? necessity,
    bool? isRecurring,
    ExpenseFrequency? frequency,
    ExpenseStatus? status,
    DateTime? endDate,
    String? budgetId,
    String? paymentMethod,
    List<String>? tags,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
      accountId: accountId ?? this.accountId,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      dueDate: dueDate ?? this.dueDate,
      necessity: necessity ?? this.necessity,
      isRecurring: isRecurring ?? this.isRecurring,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      endDate: endDate ?? this.endDate,
      budgetId: budgetId ?? this.budgetId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'categoryId': categoryId,
      'notes': notes,
      'accountId': accountId,
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'necessity': necessity.index,
      'isRecurring': isRecurring,
      'frequency': frequency.index,
      'status': status.index,
      'endDate': endDate?.toIso8601String(),
      'budgetId': budgetId,
      'paymentMethod': paymentMethod,
      'tags': tags,
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
      accountId: json['accountId'],
      nextBillingDate: json['nextBillingDate'] != null
          ? DateTime.parse(json['nextBillingDate'])
          : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      necessity: json['necessity'] != null
          ? ExpenseNecessity.values[json['necessity'] as int]
          : ExpenseNecessity.discretionary,
      isRecurring: json['isRecurring'] ?? false,
      frequency: json['frequency'] != null
          ? ExpenseFrequency.values[json['frequency'] as int]
          : ExpenseFrequency.oneTime,
      status: json['status'] != null
          ? ExpenseStatus.values[json['status'] as int]
          : ExpenseStatus.paid,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      budgetId: json['budgetId'],
      paymentMethod: json['paymentMethod'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
}

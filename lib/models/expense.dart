class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date; // Transaction date (just the date, no time)
  final DateTime createdAt; // For sorting same-day items
  final String? category;
  final String? notes;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required DateTime date,
    DateTime? createdAt,
    this.category,
    this.notes,
  })  : date = DateTime(
            date.year, date.month, date.day), // Normalize to start of day
        createdAt = createdAt ?? DateTime.now();

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
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date']);
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      date: DateTime(
          date.year, date.month, date.day), // Normalize to start of day
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      category: json['category'],
      notes: json['notes'],
    );
  }
}

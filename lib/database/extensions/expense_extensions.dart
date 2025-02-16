import 'package:drift/drift.dart';
import '../../models/expense.dart' as domain;
import '../database.dart';
import '../tables/expenses_table.dart' as tables;

extension ExpenseConversions on ExpenseTableData {
  domain.Expense toDomain() {
    return domain.Expense(
      id: id,
      title: title,
      amount: amount,
      date: date,
      createdAt: createdAt,
      categoryId: categoryId,
      notes: notes,
      type: domain.ExpenseType.values[type.index],
      accountId: accountId,
      billingCycle: billingCycle,
      nextBillingDate: nextBillingDate,
      dueDate: dueDate,
    );
  }
}

extension ExpenseTableConversion on domain.Expense {
  ExpensesTableCompanion toCompanion() {
    return ExpensesTableCompanion(
      id: Value(id),
      title: Value(title),
      amount: Value(amount),
      date: Value(date),
      createdAt: Value(createdAt),
      categoryId: Value(categoryId),
      notes: Value(notes),
      type: Value(tables.ExpenseType.values[type.index]),
      accountId: Value(accountId),
      billingCycle: Value(billingCycle),
      nextBillingDate: Value(nextBillingDate),
      dueDate: Value(dueDate),
    );
  }
} 
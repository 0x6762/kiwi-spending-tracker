import 'package:drift/drift.dart';
import '../../models/expense.dart' as domain;
import '../database.dart';

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
      accountId: accountId,
      nextBillingDate: nextBillingDate,
      dueDate: dueDate,
      necessity: domain.ExpenseNecessity.values[necessity.index],
      isRecurring: isRecurring,
      frequency: domain.ExpenseFrequency.values[frequency.index],
      status: domain.ExpenseStatus.values[status.index],
      endDate: endDate,
      budgetId: budgetId,
      paymentMethod: paymentMethod,
      tags: tags,
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
      accountId: Value(accountId),
      nextBillingDate: Value(nextBillingDate),
      dueDate: Value(dueDate),
      necessity: Value(necessity),
      isRecurring: Value(isRecurring),
      frequency: Value(frequency),
      status: Value(status),
      endDate: Value(endDate),
      budgetId: Value(budgetId),
      paymentMethod: Value(paymentMethod),
      tags: Value(tags),
    );
  }
}

import 'package:drift/drift.dart';

enum ExpenseType {
  subscription,  // Fixed recurring (Netflix, Spotify)
  fixed,        // Variable recurring (Electricity, Water)
  variable      // Variable Variable (Groceries, Entertainment)
}

@DataClassName('ExpenseTableData')
class ExpensesTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  RealColumn get amount => real()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get type => intEnum<ExpenseType>()();
  TextColumn get accountId => text()();
  TextColumn get billingCycle => text().nullable()();
  DateTimeColumn get nextBillingDate => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
} 
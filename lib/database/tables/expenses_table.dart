import 'package:drift/drift.dart';
import '../../models/expense.dart';

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
  
  // Type-specific fields
  TextColumn get billingCycle => text().nullable()();
  DateTimeColumn get nextBillingDate => dateTime().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  
  // Enhanced classification
  IntColumn get necessity => intEnum<ExpenseNecessity>().withDefault(const Constant(1))(); // Default to discretionary
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  IntColumn get frequency => intEnum<ExpenseFrequency>().withDefault(const Constant(0))(); // Default to oneTime
  IntColumn get status => intEnum<ExpenseStatus>().withDefault(const Constant(1))(); // Default to paid
  
  // New fields
  RealColumn get variableAmount => real().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get budgetId => text().nullable()();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get tags => text().map(NullAwareTypeConverter.wrap(const TagsConverter())).nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Converter for List<String> to String and back
class TagsConverter extends TypeConverter<List<String>, String> {
  const TagsConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    return fromDb.split(',').where((tag) => tag.isNotEmpty).toList();
  }

  @override
  String toSql(List<String> value) {
    if (value.isEmpty) return '';
    return value.join(',');
  }
} 
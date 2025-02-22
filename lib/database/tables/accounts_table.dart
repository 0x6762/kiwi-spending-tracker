import 'package:drift/drift.dart';

class AccountsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get iconCodePoint => integer()();
  TextColumn get iconFontFamily => text().nullable()();
  TextColumn get iconFontPackage => text().nullable()();
  BoolColumn get iconMatchTextDirection => boolean().withDefault(const Constant(false))();
  IntColumn get color => integer()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isModified => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
} 
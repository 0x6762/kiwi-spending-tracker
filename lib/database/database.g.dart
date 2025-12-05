// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ExpensesTableTable extends ExpensesTable
    with TableInfo<$ExpensesTableTable, ExpenseTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nextBillingDateMeta =
      const VerificationMeta('nextBillingDate');
  @override
  late final GeneratedColumn<DateTime> nextBillingDate =
      GeneratedColumn<DateTime>('next_billing_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _necessityMeta =
      const VerificationMeta('necessity');
  @override
  late final GeneratedColumnWithTypeConverter<ExpenseNecessity, int> necessity =
      GeneratedColumn<int>('necessity', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(1))
          .withConverter<ExpenseNecessity>(
              $ExpensesTableTable.$converternecessity);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumnWithTypeConverter<ExpenseFrequency, int> frequency =
      GeneratedColumn<int>('frequency', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<ExpenseFrequency>(
              $ExpensesTableTable.$converterfrequency);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumnWithTypeConverter<ExpenseStatus, int> status =
      GeneratedColumn<int>('status', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(1))
          .withConverter<ExpenseStatus>($ExpensesTableTable.$converterstatus);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _budgetIdMeta =
      const VerificationMeta('budgetId');
  @override
  late final GeneratedColumn<String> budgetId = GeneratedColumn<String>(
      'budget_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> tags =
      GeneratedColumn<String>('tags', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<List<String>?>($ExpensesTableTable.$convertertags);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        amount,
        date,
        createdAt,
        categoryId,
        notes,
        accountId,
        nextBillingDate,
        dueDate,
        necessity,
        isRecurring,
        frequency,
        status,
        endDate,
        budgetId,
        paymentMethod,
        tags
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses_table';
  @override
  VerificationContext validateIntegrity(Insertable<ExpenseTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('next_billing_date')) {
      context.handle(
          _nextBillingDateMeta,
          nextBillingDate.isAcceptableOrUnknown(
              data['next_billing_date']!, _nextBillingDateMeta));
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    context.handle(_necessityMeta, const VerificationResult.success());
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    context.handle(_frequencyMeta, const VerificationResult.success());
    context.handle(_statusMeta, const VerificationResult.success());
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('budget_id')) {
      context.handle(_budgetIdMeta,
          budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta));
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    context.handle(_tagsMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id'])!,
      nextBillingDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_billing_date']),
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      necessity: $ExpensesTableTable.$converternecessity.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}necessity'])!),
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      frequency: $ExpensesTableTable.$converterfrequency.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}frequency'])!),
      status: $ExpensesTableTable.$converterstatus.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!),
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      budgetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}budget_id']),
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method']),
      tags: $ExpensesTableTable.$convertertags.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])),
    );
  }

  @override
  $ExpensesTableTable createAlias(String alias) {
    return $ExpensesTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ExpenseNecessity, int, int> $converternecessity =
      const EnumIndexConverter<ExpenseNecessity>(ExpenseNecessity.values);
  static JsonTypeConverter2<ExpenseFrequency, int, int> $converterfrequency =
      const EnumIndexConverter<ExpenseFrequency>(ExpenseFrequency.values);
  static JsonTypeConverter2<ExpenseStatus, int, int> $converterstatus =
      const EnumIndexConverter<ExpenseStatus>(ExpenseStatus.values);
  static TypeConverter<List<String>?, String?> $convertertags =
      NullAwareTypeConverter.wrap(const TagsConverter());
}

class ExpenseTableData extends DataClass
    implements Insertable<ExpenseTableData> {
  final String id;
  final String title;
  final String? description;
  final double amount;
  final DateTime date;
  final DateTime createdAt;
  final String? categoryId;
  final String? notes;
  final String accountId;
  final DateTime? nextBillingDate;
  final DateTime? dueDate;
  final ExpenseNecessity necessity;
  final bool isRecurring;
  final ExpenseFrequency frequency;
  final ExpenseStatus status;
  final DateTime? endDate;
  final String? budgetId;
  final String? paymentMethod;
  final List<String>? tags;
  const ExpenseTableData(
      {required this.id,
      required this.title,
      this.description,
      required this.amount,
      required this.date,
      required this.createdAt,
      this.categoryId,
      this.notes,
      required this.accountId,
      this.nextBillingDate,
      this.dueDate,
      required this.necessity,
      required this.isRecurring,
      required this.frequency,
      required this.status,
      this.endDate,
      this.budgetId,
      this.paymentMethod,
      this.tags});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || nextBillingDate != null) {
      map['next_billing_date'] = Variable<DateTime>(nextBillingDate);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    {
      map['necessity'] = Variable<int>(
          $ExpensesTableTable.$converternecessity.toSql(necessity));
    }
    map['is_recurring'] = Variable<bool>(isRecurring);
    {
      map['frequency'] = Variable<int>(
          $ExpensesTableTable.$converterfrequency.toSql(frequency));
    }
    {
      map['status'] =
          Variable<int>($ExpensesTableTable.$converterstatus.toSql(status));
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || budgetId != null) {
      map['budget_id'] = Variable<String>(budgetId);
    }
    if (!nullToAbsent || paymentMethod != null) {
      map['payment_method'] = Variable<String>(paymentMethod);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] =
          Variable<String>($ExpensesTableTable.$convertertags.toSql(tags));
    }
    return map;
  }

  ExpensesTableCompanion toCompanion(bool nullToAbsent) {
    return ExpensesTableCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      amount: Value(amount),
      date: Value(date),
      createdAt: Value(createdAt),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      accountId: Value(accountId),
      nextBillingDate: nextBillingDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextBillingDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      necessity: Value(necessity),
      isRecurring: Value(isRecurring),
      frequency: Value(frequency),
      status: Value(status),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      budgetId: budgetId == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetId),
      paymentMethod: paymentMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethod),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
    );
  }

  factory ExpenseTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      notes: serializer.fromJson<String?>(json['notes']),
      accountId: serializer.fromJson<String>(json['accountId']),
      nextBillingDate: serializer.fromJson<DateTime?>(json['nextBillingDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      necessity: $ExpensesTableTable.$converternecessity
          .fromJson(serializer.fromJson<int>(json['necessity'])),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      frequency: $ExpensesTableTable.$converterfrequency
          .fromJson(serializer.fromJson<int>(json['frequency'])),
      status: $ExpensesTableTable.$converterstatus
          .fromJson(serializer.fromJson<int>(json['status'])),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      budgetId: serializer.fromJson<String?>(json['budgetId']),
      paymentMethod: serializer.fromJson<String?>(json['paymentMethod']),
      tags: serializer.fromJson<List<String>?>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'categoryId': serializer.toJson<String?>(categoryId),
      'notes': serializer.toJson<String?>(notes),
      'accountId': serializer.toJson<String>(accountId),
      'nextBillingDate': serializer.toJson<DateTime?>(nextBillingDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'necessity': serializer.toJson<int>(
          $ExpensesTableTable.$converternecessity.toJson(necessity)),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'frequency': serializer.toJson<int>(
          $ExpensesTableTable.$converterfrequency.toJson(frequency)),
      'status': serializer
          .toJson<int>($ExpensesTableTable.$converterstatus.toJson(status)),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'budgetId': serializer.toJson<String?>(budgetId),
      'paymentMethod': serializer.toJson<String?>(paymentMethod),
      'tags': serializer.toJson<List<String>?>(tags),
    };
  }

  ExpenseTableData copyWith(
          {String? id,
          String? title,
          Value<String?> description = const Value.absent(),
          double? amount,
          DateTime? date,
          DateTime? createdAt,
          Value<String?> categoryId = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? accountId,
          Value<DateTime?> nextBillingDate = const Value.absent(),
          Value<DateTime?> dueDate = const Value.absent(),
          ExpenseNecessity? necessity,
          bool? isRecurring,
          ExpenseFrequency? frequency,
          ExpenseStatus? status,
          Value<DateTime?> endDate = const Value.absent(),
          Value<String?> budgetId = const Value.absent(),
          Value<String?> paymentMethod = const Value.absent(),
          Value<List<String>?> tags = const Value.absent()}) =>
      ExpenseTableData(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        notes: notes.present ? notes.value : this.notes,
        accountId: accountId ?? this.accountId,
        nextBillingDate: nextBillingDate.present
            ? nextBillingDate.value
            : this.nextBillingDate,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        necessity: necessity ?? this.necessity,
        isRecurring: isRecurring ?? this.isRecurring,
        frequency: frequency ?? this.frequency,
        status: status ?? this.status,
        endDate: endDate.present ? endDate.value : this.endDate,
        budgetId: budgetId.present ? budgetId.value : this.budgetId,
        paymentMethod:
            paymentMethod.present ? paymentMethod.value : this.paymentMethod,
        tags: tags.present ? tags.value : this.tags,
      );
  ExpenseTableData copyWithCompanion(ExpensesTableCompanion data) {
    return ExpenseTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      notes: data.notes.present ? data.notes.value : this.notes,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      nextBillingDate: data.nextBillingDate.present
          ? data.nextBillingDate.value
          : this.nextBillingDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      necessity: data.necessity.present ? data.necessity.value : this.necessity,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      status: data.status.present ? data.status.value : this.status,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('categoryId: $categoryId, ')
          ..write('notes: $notes, ')
          ..write('accountId: $accountId, ')
          ..write('nextBillingDate: $nextBillingDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('necessity: $necessity, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('frequency: $frequency, ')
          ..write('status: $status, ')
          ..write('endDate: $endDate, ')
          ..write('budgetId: $budgetId, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      amount,
      date,
      createdAt,
      categoryId,
      notes,
      accountId,
      nextBillingDate,
      dueDate,
      necessity,
      isRecurring,
      frequency,
      status,
      endDate,
      budgetId,
      paymentMethod,
      tags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.categoryId == this.categoryId &&
          other.notes == this.notes &&
          other.accountId == this.accountId &&
          other.nextBillingDate == this.nextBillingDate &&
          other.dueDate == this.dueDate &&
          other.necessity == this.necessity &&
          other.isRecurring == this.isRecurring &&
          other.frequency == this.frequency &&
          other.status == this.status &&
          other.endDate == this.endDate &&
          other.budgetId == this.budgetId &&
          other.paymentMethod == this.paymentMethod &&
          other.tags == this.tags);
}

class ExpensesTableCompanion extends UpdateCompanion<ExpenseTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<String?> categoryId;
  final Value<String?> notes;
  final Value<String> accountId;
  final Value<DateTime?> nextBillingDate;
  final Value<DateTime?> dueDate;
  final Value<ExpenseNecessity> necessity;
  final Value<bool> isRecurring;
  final Value<ExpenseFrequency> frequency;
  final Value<ExpenseStatus> status;
  final Value<DateTime?> endDate;
  final Value<String?> budgetId;
  final Value<String?> paymentMethod;
  final Value<List<String>?> tags;
  final Value<int> rowid;
  const ExpensesTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.notes = const Value.absent(),
    this.accountId = const Value.absent(),
    this.nextBillingDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.necessity = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.frequency = const Value.absent(),
    this.status = const Value.absent(),
    this.endDate = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesTableCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required double amount,
    required DateTime date,
    required DateTime createdAt,
    this.categoryId = const Value.absent(),
    this.notes = const Value.absent(),
    required String accountId,
    this.nextBillingDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.necessity = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.frequency = const Value.absent(),
    this.status = const Value.absent(),
    this.endDate = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        amount = Value(amount),
        date = Value(date),
        createdAt = Value(createdAt),
        accountId = Value(accountId);
  static Insertable<ExpenseTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<String>? categoryId,
    Expression<String>? notes,
    Expression<String>? accountId,
    Expression<DateTime>? nextBillingDate,
    Expression<DateTime>? dueDate,
    Expression<int>? necessity,
    Expression<bool>? isRecurring,
    Expression<int>? frequency,
    Expression<int>? status,
    Expression<DateTime>? endDate,
    Expression<String>? budgetId,
    Expression<String>? paymentMethod,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (categoryId != null) 'category_id': categoryId,
      if (notes != null) 'notes': notes,
      if (accountId != null) 'account_id': accountId,
      if (nextBillingDate != null) 'next_billing_date': nextBillingDate,
      if (dueDate != null) 'due_date': dueDate,
      if (necessity != null) 'necessity': necessity,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (frequency != null) 'frequency': frequency,
      if (status != null) 'status': status,
      if (endDate != null) 'end_date': endDate,
      if (budgetId != null) 'budget_id': budgetId,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<double>? amount,
      Value<DateTime>? date,
      Value<DateTime>? createdAt,
      Value<String?>? categoryId,
      Value<String?>? notes,
      Value<String>? accountId,
      Value<DateTime?>? nextBillingDate,
      Value<DateTime?>? dueDate,
      Value<ExpenseNecessity>? necessity,
      Value<bool>? isRecurring,
      Value<ExpenseFrequency>? frequency,
      Value<ExpenseStatus>? status,
      Value<DateTime?>? endDate,
      Value<String?>? budgetId,
      Value<String?>? paymentMethod,
      Value<List<String>?>? tags,
      Value<int>? rowid}) {
    return ExpensesTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
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
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (nextBillingDate.present) {
      map['next_billing_date'] = Variable<DateTime>(nextBillingDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (necessity.present) {
      map['necessity'] = Variable<int>(
          $ExpensesTableTable.$converternecessity.toSql(necessity.value));
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(
          $ExpensesTableTable.$converterfrequency.toSql(frequency.value));
    }
    if (status.present) {
      map['status'] = Variable<int>(
          $ExpensesTableTable.$converterstatus.toSql(status.value));
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<String>(budgetId.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
          $ExpensesTableTable.$convertertags.toSql(tags.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('categoryId: $categoryId, ')
          ..write('notes: $notes, ')
          ..write('accountId: $accountId, ')
          ..write('nextBillingDate: $nextBillingDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('necessity: $necessity, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('frequency: $frequency, ')
          ..write('status: $status, ')
          ..write('endDate: $endDate, ')
          ..write('budgetId: $budgetId, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTableTable extends CategoriesTable
    with TableInfo<$CategoriesTableTable, CategoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconCodePointMeta =
      const VerificationMeta('iconCodePoint');
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
      'icon_code_point', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _iconFontFamilyMeta =
      const VerificationMeta('iconFontFamily');
  @override
  late final GeneratedColumn<String> iconFontFamily = GeneratedColumn<String>(
      'icon_font_family', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconFontPackageMeta =
      const VerificationMeta('iconFontPackage');
  @override
  late final GeneratedColumn<String> iconFontPackage = GeneratedColumn<String>(
      'icon_font_package', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconMatchTextDirectionMeta =
      const VerificationMeta('iconMatchTextDirection');
  @override
  late final GeneratedColumn<bool> iconMatchTextDirection =
      GeneratedColumn<bool>('icon_match_text_direction', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("icon_match_text_direction" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isModifiedMeta =
      const VerificationMeta('isModified');
  @override
  late final GeneratedColumn<bool> isModified = GeneratedColumn<bool>(
      'is_modified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_modified" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        iconCodePoint,
        iconFontFamily,
        iconFontPackage,
        iconMatchTextDirection,
        isDefault,
        isModified
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories_table';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
          _iconCodePointMeta,
          iconCodePoint.isAcceptableOrUnknown(
              data['icon_code_point']!, _iconCodePointMeta));
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('icon_font_family')) {
      context.handle(
          _iconFontFamilyMeta,
          iconFontFamily.isAcceptableOrUnknown(
              data['icon_font_family']!, _iconFontFamilyMeta));
    }
    if (data.containsKey('icon_font_package')) {
      context.handle(
          _iconFontPackageMeta,
          iconFontPackage.isAcceptableOrUnknown(
              data['icon_font_package']!, _iconFontPackageMeta));
    }
    if (data.containsKey('icon_match_text_direction')) {
      context.handle(
          _iconMatchTextDirectionMeta,
          iconMatchTextDirection.isAcceptableOrUnknown(
              data['icon_match_text_direction']!, _iconMatchTextDirectionMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('is_modified')) {
      context.handle(
          _isModifiedMeta,
          isModified.isAcceptableOrUnknown(
              data['is_modified']!, _isModifiedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconCodePoint: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}icon_code_point'])!,
      iconFontFamily: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}icon_font_family']),
      iconFontPackage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}icon_font_package']),
      iconMatchTextDirection: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}icon_match_text_direction'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      isModified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_modified'])!,
    );
  }

  @override
  $CategoriesTableTable createAlias(String alias) {
    return $CategoriesTableTable(attachedDatabase, alias);
  }
}

class CategoryTableData extends DataClass
    implements Insertable<CategoryTableData> {
  final String id;
  final String name;
  final int iconCodePoint;
  final String? iconFontFamily;
  final String? iconFontPackage;
  final bool iconMatchTextDirection;
  final bool isDefault;
  final bool isModified;
  const CategoryTableData(
      {required this.id,
      required this.name,
      required this.iconCodePoint,
      this.iconFontFamily,
      this.iconFontPackage,
      required this.iconMatchTextDirection,
      required this.isDefault,
      required this.isModified});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    if (!nullToAbsent || iconFontFamily != null) {
      map['icon_font_family'] = Variable<String>(iconFontFamily);
    }
    if (!nullToAbsent || iconFontPackage != null) {
      map['icon_font_package'] = Variable<String>(iconFontPackage);
    }
    map['icon_match_text_direction'] = Variable<bool>(iconMatchTextDirection);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_modified'] = Variable<bool>(isModified);
    return map;
  }

  CategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return CategoriesTableCompanion(
      id: Value(id),
      name: Value(name),
      iconCodePoint: Value(iconCodePoint),
      iconFontFamily: iconFontFamily == null && nullToAbsent
          ? const Value.absent()
          : Value(iconFontFamily),
      iconFontPackage: iconFontPackage == null && nullToAbsent
          ? const Value.absent()
          : Value(iconFontPackage),
      iconMatchTextDirection: Value(iconMatchTextDirection),
      isDefault: Value(isDefault),
      isModified: Value(isModified),
    );
  }

  factory CategoryTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      iconFontFamily: serializer.fromJson<String?>(json['iconFontFamily']),
      iconFontPackage: serializer.fromJson<String?>(json['iconFontPackage']),
      iconMatchTextDirection:
          serializer.fromJson<bool>(json['iconMatchTextDirection']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isModified: serializer.fromJson<bool>(json['isModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'iconFontFamily': serializer.toJson<String?>(iconFontFamily),
      'iconFontPackage': serializer.toJson<String?>(iconFontPackage),
      'iconMatchTextDirection': serializer.toJson<bool>(iconMatchTextDirection),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isModified': serializer.toJson<bool>(isModified),
    };
  }

  CategoryTableData copyWith(
          {String? id,
          String? name,
          int? iconCodePoint,
          Value<String?> iconFontFamily = const Value.absent(),
          Value<String?> iconFontPackage = const Value.absent(),
          bool? iconMatchTextDirection,
          bool? isDefault,
          bool? isModified}) =>
      CategoryTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        iconCodePoint: iconCodePoint ?? this.iconCodePoint,
        iconFontFamily:
            iconFontFamily.present ? iconFontFamily.value : this.iconFontFamily,
        iconFontPackage: iconFontPackage.present
            ? iconFontPackage.value
            : this.iconFontPackage,
        iconMatchTextDirection:
            iconMatchTextDirection ?? this.iconMatchTextDirection,
        isDefault: isDefault ?? this.isDefault,
        isModified: isModified ?? this.isModified,
      );
  CategoryTableData copyWithCompanion(CategoriesTableCompanion data) {
    return CategoryTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      iconFontFamily: data.iconFontFamily.present
          ? data.iconFontFamily.value
          : this.iconFontFamily,
      iconFontPackage: data.iconFontPackage.present
          ? data.iconFontPackage.value
          : this.iconFontPackage,
      iconMatchTextDirection: data.iconMatchTextDirection.present
          ? data.iconMatchTextDirection.value
          : this.iconMatchTextDirection,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isModified:
          data.isModified.present ? data.isModified.value : this.isModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('iconFontFamily: $iconFontFamily, ')
          ..write('iconFontPackage: $iconFontPackage, ')
          ..write('iconMatchTextDirection: $iconMatchTextDirection, ')
          ..write('isDefault: $isDefault, ')
          ..write('isModified: $isModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iconCodePoint, iconFontFamily,
      iconFontPackage, iconMatchTextDirection, isDefault, isModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconCodePoint == this.iconCodePoint &&
          other.iconFontFamily == this.iconFontFamily &&
          other.iconFontPackage == this.iconFontPackage &&
          other.iconMatchTextDirection == this.iconMatchTextDirection &&
          other.isDefault == this.isDefault &&
          other.isModified == this.isModified);
}

class CategoriesTableCompanion extends UpdateCompanion<CategoryTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> iconCodePoint;
  final Value<String?> iconFontFamily;
  final Value<String?> iconFontPackage;
  final Value<bool> iconMatchTextDirection;
  final Value<bool> isDefault;
  final Value<bool> isModified;
  final Value<int> rowid;
  const CategoriesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.iconFontFamily = const Value.absent(),
    this.iconFontPackage = const Value.absent(),
    this.iconMatchTextDirection = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesTableCompanion.insert({
    required String id,
    required String name,
    required int iconCodePoint,
    this.iconFontFamily = const Value.absent(),
    this.iconFontPackage = const Value.absent(),
    this.iconMatchTextDirection = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isModified = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        iconCodePoint = Value(iconCodePoint);
  static Insertable<CategoryTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? iconCodePoint,
    Expression<String>? iconFontFamily,
    Expression<String>? iconFontPackage,
    Expression<bool>? iconMatchTextDirection,
    Expression<bool>? isDefault,
    Expression<bool>? isModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (iconFontFamily != null) 'icon_font_family': iconFontFamily,
      if (iconFontPackage != null) 'icon_font_package': iconFontPackage,
      if (iconMatchTextDirection != null)
        'icon_match_text_direction': iconMatchTextDirection,
      if (isDefault != null) 'is_default': isDefault,
      if (isModified != null) 'is_modified': isModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? iconCodePoint,
      Value<String?>? iconFontFamily,
      Value<String?>? iconFontPackage,
      Value<bool>? iconMatchTextDirection,
      Value<bool>? isDefault,
      Value<bool>? isModified,
      Value<int>? rowid}) {
    return CategoriesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      iconFontPackage: iconFontPackage ?? this.iconFontPackage,
      iconMatchTextDirection:
          iconMatchTextDirection ?? this.iconMatchTextDirection,
      isDefault: isDefault ?? this.isDefault,
      isModified: isModified ?? this.isModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (iconFontFamily.present) {
      map['icon_font_family'] = Variable<String>(iconFontFamily.value);
    }
    if (iconFontPackage.present) {
      map['icon_font_package'] = Variable<String>(iconFontPackage.value);
    }
    if (iconMatchTextDirection.present) {
      map['icon_match_text_direction'] =
          Variable<bool>(iconMatchTextDirection.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isModified.present) {
      map['is_modified'] = Variable<bool>(isModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('iconFontFamily: $iconFontFamily, ')
          ..write('iconFontPackage: $iconFontPackage, ')
          ..write('iconMatchTextDirection: $iconMatchTextDirection, ')
          ..write('isDefault: $isDefault, ')
          ..write('isModified: $isModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AccountsTableTable extends AccountsTable
    with TableInfo<$AccountsTableTable, AccountsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconCodePointMeta =
      const VerificationMeta('iconCodePoint');
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
      'icon_code_point', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _iconFontFamilyMeta =
      const VerificationMeta('iconFontFamily');
  @override
  late final GeneratedColumn<String> iconFontFamily = GeneratedColumn<String>(
      'icon_font_family', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconFontPackageMeta =
      const VerificationMeta('iconFontPackage');
  @override
  late final GeneratedColumn<String> iconFontPackage = GeneratedColumn<String>(
      'icon_font_package', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconMatchTextDirectionMeta =
      const VerificationMeta('iconMatchTextDirection');
  @override
  late final GeneratedColumn<bool> iconMatchTextDirection =
      GeneratedColumn<bool>('icon_match_text_direction', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("icon_match_text_direction" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isModifiedMeta =
      const VerificationMeta('isModified');
  @override
  late final GeneratedColumn<bool> isModified = GeneratedColumn<bool>(
      'is_modified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_modified" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        iconCodePoint,
        iconFontFamily,
        iconFontPackage,
        iconMatchTextDirection,
        color,
        isDefault,
        isModified
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts_table';
  @override
  VerificationContext validateIntegrity(Insertable<AccountsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
          _iconCodePointMeta,
          iconCodePoint.isAcceptableOrUnknown(
              data['icon_code_point']!, _iconCodePointMeta));
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('icon_font_family')) {
      context.handle(
          _iconFontFamilyMeta,
          iconFontFamily.isAcceptableOrUnknown(
              data['icon_font_family']!, _iconFontFamilyMeta));
    }
    if (data.containsKey('icon_font_package')) {
      context.handle(
          _iconFontPackageMeta,
          iconFontPackage.isAcceptableOrUnknown(
              data['icon_font_package']!, _iconFontPackageMeta));
    }
    if (data.containsKey('icon_match_text_direction')) {
      context.handle(
          _iconMatchTextDirectionMeta,
          iconMatchTextDirection.isAcceptableOrUnknown(
              data['icon_match_text_direction']!, _iconMatchTextDirectionMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('is_modified')) {
      context.handle(
          _isModifiedMeta,
          isModified.isAcceptableOrUnknown(
              data['is_modified']!, _isModifiedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconCodePoint: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}icon_code_point'])!,
      iconFontFamily: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}icon_font_family']),
      iconFontPackage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}icon_font_package']),
      iconMatchTextDirection: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}icon_match_text_direction'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      isModified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_modified'])!,
    );
  }

  @override
  $AccountsTableTable createAlias(String alias) {
    return $AccountsTableTable(attachedDatabase, alias);
  }
}

class AccountsTableData extends DataClass
    implements Insertable<AccountsTableData> {
  final String id;
  final String name;
  final int iconCodePoint;
  final String? iconFontFamily;
  final String? iconFontPackage;
  final bool iconMatchTextDirection;
  final int color;
  final bool isDefault;
  final bool isModified;
  const AccountsTableData(
      {required this.id,
      required this.name,
      required this.iconCodePoint,
      this.iconFontFamily,
      this.iconFontPackage,
      required this.iconMatchTextDirection,
      required this.color,
      required this.isDefault,
      required this.isModified});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    if (!nullToAbsent || iconFontFamily != null) {
      map['icon_font_family'] = Variable<String>(iconFontFamily);
    }
    if (!nullToAbsent || iconFontPackage != null) {
      map['icon_font_package'] = Variable<String>(iconFontPackage);
    }
    map['icon_match_text_direction'] = Variable<bool>(iconMatchTextDirection);
    map['color'] = Variable<int>(color);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_modified'] = Variable<bool>(isModified);
    return map;
  }

  AccountsTableCompanion toCompanion(bool nullToAbsent) {
    return AccountsTableCompanion(
      id: Value(id),
      name: Value(name),
      iconCodePoint: Value(iconCodePoint),
      iconFontFamily: iconFontFamily == null && nullToAbsent
          ? const Value.absent()
          : Value(iconFontFamily),
      iconFontPackage: iconFontPackage == null && nullToAbsent
          ? const Value.absent()
          : Value(iconFontPackage),
      iconMatchTextDirection: Value(iconMatchTextDirection),
      color: Value(color),
      isDefault: Value(isDefault),
      isModified: Value(isModified),
    );
  }

  factory AccountsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      iconFontFamily: serializer.fromJson<String?>(json['iconFontFamily']),
      iconFontPackage: serializer.fromJson<String?>(json['iconFontPackage']),
      iconMatchTextDirection:
          serializer.fromJson<bool>(json['iconMatchTextDirection']),
      color: serializer.fromJson<int>(json['color']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isModified: serializer.fromJson<bool>(json['isModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'iconFontFamily': serializer.toJson<String?>(iconFontFamily),
      'iconFontPackage': serializer.toJson<String?>(iconFontPackage),
      'iconMatchTextDirection': serializer.toJson<bool>(iconMatchTextDirection),
      'color': serializer.toJson<int>(color),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isModified': serializer.toJson<bool>(isModified),
    };
  }

  AccountsTableData copyWith(
          {String? id,
          String? name,
          int? iconCodePoint,
          Value<String?> iconFontFamily = const Value.absent(),
          Value<String?> iconFontPackage = const Value.absent(),
          bool? iconMatchTextDirection,
          int? color,
          bool? isDefault,
          bool? isModified}) =>
      AccountsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        iconCodePoint: iconCodePoint ?? this.iconCodePoint,
        iconFontFamily:
            iconFontFamily.present ? iconFontFamily.value : this.iconFontFamily,
        iconFontPackage: iconFontPackage.present
            ? iconFontPackage.value
            : this.iconFontPackage,
        iconMatchTextDirection:
            iconMatchTextDirection ?? this.iconMatchTextDirection,
        color: color ?? this.color,
        isDefault: isDefault ?? this.isDefault,
        isModified: isModified ?? this.isModified,
      );
  AccountsTableData copyWithCompanion(AccountsTableCompanion data) {
    return AccountsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      iconFontFamily: data.iconFontFamily.present
          ? data.iconFontFamily.value
          : this.iconFontFamily,
      iconFontPackage: data.iconFontPackage.present
          ? data.iconFontPackage.value
          : this.iconFontPackage,
      iconMatchTextDirection: data.iconMatchTextDirection.present
          ? data.iconMatchTextDirection.value
          : this.iconMatchTextDirection,
      color: data.color.present ? data.color.value : this.color,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isModified:
          data.isModified.present ? data.isModified.value : this.isModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('iconFontFamily: $iconFontFamily, ')
          ..write('iconFontPackage: $iconFontPackage, ')
          ..write('iconMatchTextDirection: $iconMatchTextDirection, ')
          ..write('color: $color, ')
          ..write('isDefault: $isDefault, ')
          ..write('isModified: $isModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iconCodePoint, iconFontFamily,
      iconFontPackage, iconMatchTextDirection, color, isDefault, isModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconCodePoint == this.iconCodePoint &&
          other.iconFontFamily == this.iconFontFamily &&
          other.iconFontPackage == this.iconFontPackage &&
          other.iconMatchTextDirection == this.iconMatchTextDirection &&
          other.color == this.color &&
          other.isDefault == this.isDefault &&
          other.isModified == this.isModified);
}

class AccountsTableCompanion extends UpdateCompanion<AccountsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> iconCodePoint;
  final Value<String?> iconFontFamily;
  final Value<String?> iconFontPackage;
  final Value<bool> iconMatchTextDirection;
  final Value<int> color;
  final Value<bool> isDefault;
  final Value<bool> isModified;
  final Value<int> rowid;
  const AccountsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.iconFontFamily = const Value.absent(),
    this.iconFontPackage = const Value.absent(),
    this.iconMatchTextDirection = const Value.absent(),
    this.color = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AccountsTableCompanion.insert({
    required String id,
    required String name,
    required int iconCodePoint,
    this.iconFontFamily = const Value.absent(),
    this.iconFontPackage = const Value.absent(),
    this.iconMatchTextDirection = const Value.absent(),
    required int color,
    this.isDefault = const Value.absent(),
    this.isModified = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        iconCodePoint = Value(iconCodePoint),
        color = Value(color);
  static Insertable<AccountsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? iconCodePoint,
    Expression<String>? iconFontFamily,
    Expression<String>? iconFontPackage,
    Expression<bool>? iconMatchTextDirection,
    Expression<int>? color,
    Expression<bool>? isDefault,
    Expression<bool>? isModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (iconFontFamily != null) 'icon_font_family': iconFontFamily,
      if (iconFontPackage != null) 'icon_font_package': iconFontPackage,
      if (iconMatchTextDirection != null)
        'icon_match_text_direction': iconMatchTextDirection,
      if (color != null) 'color': color,
      if (isDefault != null) 'is_default': isDefault,
      if (isModified != null) 'is_modified': isModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AccountsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? iconCodePoint,
      Value<String?>? iconFontFamily,
      Value<String?>? iconFontPackage,
      Value<bool>? iconMatchTextDirection,
      Value<int>? color,
      Value<bool>? isDefault,
      Value<bool>? isModified,
      Value<int>? rowid}) {
    return AccountsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      iconFontPackage: iconFontPackage ?? this.iconFontPackage,
      iconMatchTextDirection:
          iconMatchTextDirection ?? this.iconMatchTextDirection,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      isModified: isModified ?? this.isModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (iconFontFamily.present) {
      map['icon_font_family'] = Variable<String>(iconFontFamily.value);
    }
    if (iconFontPackage.present) {
      map['icon_font_package'] = Variable<String>(iconFontPackage.value);
    }
    if (iconMatchTextDirection.present) {
      map['icon_match_text_direction'] =
          Variable<bool>(iconMatchTextDirection.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isModified.present) {
      map['is_modified'] = Variable<bool>(isModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('iconFontFamily: $iconFontFamily, ')
          ..write('iconFontPackage: $iconFontPackage, ')
          ..write('iconMatchTextDirection: $iconMatchTextDirection, ')
          ..write('color: $color, ')
          ..write('isDefault: $isDefault, ')
          ..write('isModified: $isModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExpensesTableTable expensesTable = $ExpensesTableTable(this);
  late final $CategoriesTableTable categoriesTable =
      $CategoriesTableTable(this);
  late final $AccountsTableTable accountsTable = $AccountsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [expensesTable, categoriesTable, accountsTable];
}

typedef $$ExpensesTableTableCreateCompanionBuilder = ExpensesTableCompanion
    Function({
  required String id,
  required String title,
  Value<String?> description,
  required double amount,
  required DateTime date,
  required DateTime createdAt,
  Value<String?> categoryId,
  Value<String?> notes,
  required String accountId,
  Value<DateTime?> nextBillingDate,
  Value<DateTime?> dueDate,
  Value<ExpenseNecessity> necessity,
  Value<bool> isRecurring,
  Value<ExpenseFrequency> frequency,
  Value<ExpenseStatus> status,
  Value<DateTime?> endDate,
  Value<String?> budgetId,
  Value<String?> paymentMethod,
  Value<List<String>?> tags,
  Value<int> rowid,
});
typedef $$ExpensesTableTableUpdateCompanionBuilder = ExpensesTableCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String?> description,
  Value<double> amount,
  Value<DateTime> date,
  Value<DateTime> createdAt,
  Value<String?> categoryId,
  Value<String?> notes,
  Value<String> accountId,
  Value<DateTime?> nextBillingDate,
  Value<DateTime?> dueDate,
  Value<ExpenseNecessity> necessity,
  Value<bool> isRecurring,
  Value<ExpenseFrequency> frequency,
  Value<ExpenseStatus> status,
  Value<DateTime?> endDate,
  Value<String?> budgetId,
  Value<String?> paymentMethod,
  Value<List<String>?> tags,
  Value<int> rowid,
});

class $$ExpensesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextBillingDate => $composableBuilder(
      column: $table.nextBillingDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ExpenseNecessity, ExpenseNecessity, int>
      get necessity => $composableBuilder(
          column: $table.necessity,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ExpenseFrequency, ExpenseFrequency, int>
      get frequency => $composableBuilder(
          column: $table.frequency,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<ExpenseStatus, ExpenseStatus, int>
      get status => $composableBuilder(
          column: $table.status,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get budgetId => $composableBuilder(
      column: $table.budgetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
      get tags => $composableBuilder(
          column: $table.tags,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$ExpensesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountId => $composableBuilder(
      column: $table.accountId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextBillingDate => $composableBuilder(
      column: $table.nextBillingDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get necessity => $composableBuilder(
      column: $table.necessity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get budgetId => $composableBuilder(
      column: $table.budgetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));
}

class $$ExpensesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<DateTime> get nextBillingDate => $composableBuilder(
      column: $table.nextBillingDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExpenseNecessity, int> get necessity =>
      $composableBuilder(column: $table.necessity, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExpenseFrequency, int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExpenseStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get budgetId =>
      $composableBuilder(column: $table.budgetId, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);
}

class $$ExpensesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensesTableTable,
    ExpenseTableData,
    $$ExpensesTableTableFilterComposer,
    $$ExpensesTableTableOrderingComposer,
    $$ExpensesTableTableAnnotationComposer,
    $$ExpensesTableTableCreateCompanionBuilder,
    $$ExpensesTableTableUpdateCompanionBuilder,
    (
      ExpenseTableData,
      BaseReferences<_$AppDatabase, $ExpensesTableTable, ExpenseTableData>
    ),
    ExpenseTableData,
    PrefetchHooks Function()> {
  $$ExpensesTableTableTableManager(_$AppDatabase db, $ExpensesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> accountId = const Value.absent(),
            Value<DateTime?> nextBillingDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<ExpenseNecessity> necessity = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<ExpenseFrequency> frequency = const Value.absent(),
            Value<ExpenseStatus> status = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String?> budgetId = const Value.absent(),
            Value<String?> paymentMethod = const Value.absent(),
            Value<List<String>?> tags = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesTableCompanion(
            id: id,
            title: title,
            description: description,
            amount: amount,
            date: date,
            createdAt: createdAt,
            categoryId: categoryId,
            notes: notes,
            accountId: accountId,
            nextBillingDate: nextBillingDate,
            dueDate: dueDate,
            necessity: necessity,
            isRecurring: isRecurring,
            frequency: frequency,
            status: status,
            endDate: endDate,
            budgetId: budgetId,
            paymentMethod: paymentMethod,
            tags: tags,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String?> description = const Value.absent(),
            required double amount,
            required DateTime date,
            required DateTime createdAt,
            Value<String?> categoryId = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required String accountId,
            Value<DateTime?> nextBillingDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<ExpenseNecessity> necessity = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<ExpenseFrequency> frequency = const Value.absent(),
            Value<ExpenseStatus> status = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<String?> budgetId = const Value.absent(),
            Value<String?> paymentMethod = const Value.absent(),
            Value<List<String>?> tags = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesTableCompanion.insert(
            id: id,
            title: title,
            description: description,
            amount: amount,
            date: date,
            createdAt: createdAt,
            categoryId: categoryId,
            notes: notes,
            accountId: accountId,
            nextBillingDate: nextBillingDate,
            dueDate: dueDate,
            necessity: necessity,
            isRecurring: isRecurring,
            frequency: frequency,
            status: status,
            endDate: endDate,
            budgetId: budgetId,
            paymentMethod: paymentMethod,
            tags: tags,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ExpensesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpensesTableTable,
    ExpenseTableData,
    $$ExpensesTableTableFilterComposer,
    $$ExpensesTableTableOrderingComposer,
    $$ExpensesTableTableAnnotationComposer,
    $$ExpensesTableTableCreateCompanionBuilder,
    $$ExpensesTableTableUpdateCompanionBuilder,
    (
      ExpenseTableData,
      BaseReferences<_$AppDatabase, $ExpensesTableTable, ExpenseTableData>
    ),
    ExpenseTableData,
    PrefetchHooks Function()>;
typedef $$CategoriesTableTableCreateCompanionBuilder = CategoriesTableCompanion
    Function({
  required String id,
  required String name,
  required int iconCodePoint,
  Value<String?> iconFontFamily,
  Value<String?> iconFontPackage,
  Value<bool> iconMatchTextDirection,
  Value<bool> isDefault,
  Value<bool> isModified,
  Value<int> rowid,
});
typedef $$CategoriesTableTableUpdateCompanionBuilder = CategoriesTableCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<int> iconCodePoint,
  Value<String?> iconFontFamily,
  Value<String?> iconFontPackage,
  Value<bool> iconMatchTextDirection,
  Value<bool> isDefault,
  Value<bool> isModified,
  Value<int> rowid,
});

class $$CategoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconFontFamily => $composableBuilder(
      column: $table.iconFontFamily,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconFontPackage => $composableBuilder(
      column: $table.iconFontPackage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get iconMatchTextDirection => $composableBuilder(
      column: $table.iconMatchTextDirection,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isModified => $composableBuilder(
      column: $table.isModified, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconFontFamily => $composableBuilder(
      column: $table.iconFontFamily,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconFontPackage => $composableBuilder(
      column: $table.iconFontPackage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get iconMatchTextDirection => $composableBuilder(
      column: $table.iconMatchTextDirection,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isModified => $composableBuilder(
      column: $table.isModified, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint, builder: (column) => column);

  GeneratedColumn<String> get iconFontFamily => $composableBuilder(
      column: $table.iconFontFamily, builder: (column) => column);

  GeneratedColumn<String> get iconFontPackage => $composableBuilder(
      column: $table.iconFontPackage, builder: (column) => column);

  GeneratedColumn<bool> get iconMatchTextDirection => $composableBuilder(
      column: $table.iconMatchTextDirection, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isModified => $composableBuilder(
      column: $table.isModified, builder: (column) => column);
}

class $$CategoriesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTableTable,
    CategoryTableData,
    $$CategoriesTableTableFilterComposer,
    $$CategoriesTableTableOrderingComposer,
    $$CategoriesTableTableAnnotationComposer,
    $$CategoriesTableTableCreateCompanionBuilder,
    $$CategoriesTableTableUpdateCompanionBuilder,
    (
      CategoryTableData,
      BaseReferences<_$AppDatabase, $CategoriesTableTable, CategoryTableData>
    ),
    CategoryTableData,
    PrefetchHooks Function()> {
  $$CategoriesTableTableTableManager(
      _$AppDatabase db, $CategoriesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> iconCodePoint = const Value.absent(),
            Value<String?> iconFontFamily = const Value.absent(),
            Value<String?> iconFontPackage = const Value.absent(),
            Value<bool> iconMatchTextDirection = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isModified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesTableCompanion(
            id: id,
            name: name,
            iconCodePoint: iconCodePoint,
            iconFontFamily: iconFontFamily,
            iconFontPackage: iconFontPackage,
            iconMatchTextDirection: iconMatchTextDirection,
            isDefault: isDefault,
            isModified: isModified,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int iconCodePoint,
            Value<String?> iconFontFamily = const Value.absent(),
            Value<String?> iconFontPackage = const Value.absent(),
            Value<bool> iconMatchTextDirection = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isModified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesTableCompanion.insert(
            id: id,
            name: name,
            iconCodePoint: iconCodePoint,
            iconFontFamily: iconFontFamily,
            iconFontPackage: iconFontPackage,
            iconMatchTextDirection: iconMatchTextDirection,
            isDefault: isDefault,
            isModified: isModified,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTableTable,
    CategoryTableData,
    $$CategoriesTableTableFilterComposer,
    $$CategoriesTableTableOrderingComposer,
    $$CategoriesTableTableAnnotationComposer,
    $$CategoriesTableTableCreateCompanionBuilder,
    $$CategoriesTableTableUpdateCompanionBuilder,
    (
      CategoryTableData,
      BaseReferences<_$AppDatabase, $CategoriesTableTable, CategoryTableData>
    ),
    CategoryTableData,
    PrefetchHooks Function()>;
typedef $$AccountsTableTableCreateCompanionBuilder = AccountsTableCompanion
    Function({
  required String id,
  required String name,
  required int iconCodePoint,
  Value<String?> iconFontFamily,
  Value<String?> iconFontPackage,
  Value<bool> iconMatchTextDirection,
  required int color,
  Value<bool> isDefault,
  Value<bool> isModified,
  Value<int> rowid,
});
typedef $$AccountsTableTableUpdateCompanionBuilder = AccountsTableCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<int> iconCodePoint,
  Value<String?> iconFontFamily,
  Value<String?> iconFontPackage,
  Value<bool> iconMatchTextDirection,
  Value<int> color,
  Value<bool> isDefault,
  Value<bool> isModified,
  Value<int> rowid,
});

class $$AccountsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTableTable> {
  $$AccountsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconFontFamily => $composableBuilder(
      column: $table.iconFontFamily,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconFontPackage => $composableBuilder(
      column: $table.iconFontPackage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get iconMatchTextDirection => $composableBuilder(
      column: $table.iconMatchTextDirection,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isModified => $composableBuilder(
      column: $table.isModified, builder: (column) => ColumnFilters(column));
}

class $$AccountsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTableTable> {
  $$AccountsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconFontFamily => $composableBuilder(
      column: $table.iconFontFamily,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconFontPackage => $composableBuilder(
      column: $table.iconFontPackage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get iconMatchTextDirection => $composableBuilder(
      column: $table.iconMatchTextDirection,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isModified => $composableBuilder(
      column: $table.isModified, builder: (column) => ColumnOrderings(column));
}

class $$AccountsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTableTable> {
  $$AccountsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
      column: $table.iconCodePoint, builder: (column) => column);

  GeneratedColumn<String> get iconFontFamily => $composableBuilder(
      column: $table.iconFontFamily, builder: (column) => column);

  GeneratedColumn<String> get iconFontPackage => $composableBuilder(
      column: $table.iconFontPackage, builder: (column) => column);

  GeneratedColumn<bool> get iconMatchTextDirection => $composableBuilder(
      column: $table.iconMatchTextDirection, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isModified => $composableBuilder(
      column: $table.isModified, builder: (column) => column);
}

class $$AccountsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AccountsTableTable,
    AccountsTableData,
    $$AccountsTableTableFilterComposer,
    $$AccountsTableTableOrderingComposer,
    $$AccountsTableTableAnnotationComposer,
    $$AccountsTableTableCreateCompanionBuilder,
    $$AccountsTableTableUpdateCompanionBuilder,
    (
      AccountsTableData,
      BaseReferences<_$AppDatabase, $AccountsTableTable, AccountsTableData>
    ),
    AccountsTableData,
    PrefetchHooks Function()> {
  $$AccountsTableTableTableManager(_$AppDatabase db, $AccountsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> iconCodePoint = const Value.absent(),
            Value<String?> iconFontFamily = const Value.absent(),
            Value<String?> iconFontPackage = const Value.absent(),
            Value<bool> iconMatchTextDirection = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isModified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsTableCompanion(
            id: id,
            name: name,
            iconCodePoint: iconCodePoint,
            iconFontFamily: iconFontFamily,
            iconFontPackage: iconFontPackage,
            iconMatchTextDirection: iconMatchTextDirection,
            color: color,
            isDefault: isDefault,
            isModified: isModified,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int iconCodePoint,
            Value<String?> iconFontFamily = const Value.absent(),
            Value<String?> iconFontPackage = const Value.absent(),
            Value<bool> iconMatchTextDirection = const Value.absent(),
            required int color,
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isModified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AccountsTableCompanion.insert(
            id: id,
            name: name,
            iconCodePoint: iconCodePoint,
            iconFontFamily: iconFontFamily,
            iconFontPackage: iconFontPackage,
            iconMatchTextDirection: iconMatchTextDirection,
            color: color,
            isDefault: isDefault,
            isModified: isModified,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AccountsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AccountsTableTable,
    AccountsTableData,
    $$AccountsTableTableFilterComposer,
    $$AccountsTableTableOrderingComposer,
    $$AccountsTableTableAnnotationComposer,
    $$AccountsTableTableCreateCompanionBuilder,
    $$AccountsTableTableUpdateCompanionBuilder,
    (
      AccountsTableData,
      BaseReferences<_$AppDatabase, $AccountsTableTable, AccountsTableData>
    ),
    AccountsTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExpensesTableTableTableManager get expensesTable =>
      $$ExpensesTableTableTableManager(_db, _db.expensesTable);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(_db, _db.categoriesTable);
  $$AccountsTableTableTableManager get accountsTable =>
      $$AccountsTableTableTableManager(_db, _db.accountsTable);
}

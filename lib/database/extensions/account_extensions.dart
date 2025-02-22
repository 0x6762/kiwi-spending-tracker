import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../../models/account.dart';
import '../database.dart';

extension AccountDomainX on Account {
  AccountsTableCompanion toCompanion() {
    return AccountsTableCompanion.insert(
      id: id,
      name: name,
      iconCodePoint: icon.codePoint,
      iconFontFamily: Value(icon.fontFamily),
      iconFontPackage: Value(icon.fontPackage),
      iconMatchTextDirection: Value(icon.matchTextDirection),
      color: color.value,
      isDefault: Value(isDefault),
      isModified: Value(isModified),
    );
  }
}

extension AccountDataX on AccountsTableData {
  Account toDomain() {
    return Account(
      id: id,
      name: name,
      icon: IconData(
        iconCodePoint,
        fontFamily: iconFontFamily,
        fontPackage: iconFontPackage,
        matchTextDirection: iconMatchTextDirection,
      ),
      color: Color(color),
      isDefault: isDefault,
      isModified: isModified,
    );
  }
} 
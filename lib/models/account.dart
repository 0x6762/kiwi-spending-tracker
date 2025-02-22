import 'package:flutter/material.dart';

class Account {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isDefault;
  final bool isModified;

  const Account({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.isModified = false,
  });

  Account copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    bool? isDefault,
    bool? isModified,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      isModified: isModified ?? this.isModified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'iconMatchTextDirection': icon.matchTextDirection,
      'color': color.value,
      'isDefault': isDefault,
      'isModified': isModified,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      icon: IconData(
        json['icon'],
        fontFamily: json['iconFontFamily'],
        fontPackage: json['iconFontPackage'],
        matchTextDirection: json['iconMatchTextDirection'] ?? false,
      ),
      color: Color(json['color']),
      isDefault: json['isDefault'] ?? false,
      isModified: json['isModified'] ?? false,
    );
  }
}

class DefaultAccounts {
  static const checking = Account(
    id: 'checking',
    name: 'Checking',
    icon: Icons.account_balance,
    color: Color(0xFF2196F3), // Blue
    isDefault: true,
  );

  static const creditCard = Account(
    id: 'credit_card',
    name: 'Credit Card',
    icon: Icons.credit_card,
    color: Color(0xFF4CAF50), // Green
    isDefault: true,
  );

  static List<Account> defaultAccounts = [checking, creditCard];
}

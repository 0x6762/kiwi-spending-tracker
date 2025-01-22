import 'package:flutter/material.dart';

class Account {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const Account({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  Account copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      color: Color(json['color']),
    );
  }
}

class DefaultAccounts {
  static const checking = Account(
    id: 'checking',
    name: 'Checking',
    icon: Icons.account_balance,
    color: Color(0xFF2196F3), // Blue
  );

  static const creditCard = Account(
    id: 'credit_card',
    name: 'Credit Card',
    icon: Icons.credit_card,
    color: Color(0xFF4CAF50), // Green
  );

  static List<Account> defaultAccounts = [checking, creditCard];
}

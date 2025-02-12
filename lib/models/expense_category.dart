import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': {
        'codePoint': icon.codePoint,
        'fontFamily': icon.fontFamily,
        'fontPackage': icon.fontPackage,
        'matchTextDirection': icon.matchTextDirection,
      },
    };
  }

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    final iconData = json['icon'];
    IconData icon;
    
    if (iconData is Map) {
      // New format with full icon data
      icon = IconData(
        iconData['codePoint'],
        fontFamily: iconData['fontFamily'],
        fontPackage: iconData['fontPackage'],
        matchTextDirection: iconData['matchTextDirection'] ?? false,
      );
    } else {
      // Legacy format with just codePoint
      icon = IconData(
        iconData as int,
        fontFamily: 'MaterialIcons',
      );
    }

    // For backward compatibility, if no ID is present, use name as ID
    final id = json['id'] ?? json['name'];

    return ExpenseCategory(
      id: id,
      name: json['name'],
      icon: icon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  ExpenseCategory copyWith({
    String? id,
    String? name,
    IconData? icon,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
    );
  }
}

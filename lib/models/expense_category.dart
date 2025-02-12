import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;

  // Map of const IconData instances
  static const Map<int, IconData> _iconMap = {
    0xe318: IconData(0xe318, fontFamily: 'MaterialIcons'), // restaurant
    0xe1d5: IconData(0xe1d5, fontFamily: 'MaterialIcons'), // directions_car
    0xe59c: IconData(0xe59c, fontFamily: 'MaterialIcons'), // shopping_bag
    0xe40c: IconData(0xe40c, fontFamily: 'MaterialIcons'), // movie
    0xe4d3: IconData(0xe4d3, fontFamily: 'MaterialIcons'), // receipt
    0xe3a4: IconData(0xe3a4, fontFamily: 'MaterialIcons'), // medical_services
    0xe1d8: IconData(0xe1d8, fontFamily: 'MaterialIcons'), // flight
    0xe559: IconData(0xe559, fontFamily: 'MaterialIcons'), // school
    0xe3dc: IconData(0xe3dc, fontFamily: 'MaterialIcons'), // more_horiz
    0xe33b: IconData(0xe33b, fontFamily: 'MaterialIcons'), // help_outline
    0xe1c4: IconData(0xe1c4, fontFamily: 'MaterialIcons'), // category_outlined
  };

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

  static IconData iconFromCodePoint(int codePoint) {
    return IconData(codePoint, fontFamily: 'MaterialIcons');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Create a copy of this category with some fields replaced
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

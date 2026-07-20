import 'package:flutter/material.dart';

enum ActivityType {
  rent,
  food,
  expense,
  utility,
  settlement,
  payment
}

class Activity {
  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final int amount;
  final DateTime createdAt;
  final IconData icon;
  final Color color;
  final String? route;

  Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.createdAt,
    required this.icon,
    required this.color,
    this.route,
  });
}

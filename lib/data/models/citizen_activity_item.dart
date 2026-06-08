import 'package:flutter/material.dart';

class CitizenActivityItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime occurredAt;

  const CitizenActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.occurredAt,
  });
}

import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/field_staff/shared/stat_header.dart';

class CitizenHeader extends StatelessWidget {
  final String name;
  final String? profileImageUrl;

  const CitizenHeader({super.key, required this.name, this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return StatHeader(title: name);
  }
}

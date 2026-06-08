import 'package:flutter/material.dart';
import 'package:garbo_swms/presentation/field_staff/shared/stat_header.dart';

class HeaderReduced extends StatelessWidget {
  final String title;

  const HeaderReduced({super.key, this.title = 'Dashboard'});

  @override
  Widget build(BuildContext context) {
    return StatHeader(title: title);
  }
}

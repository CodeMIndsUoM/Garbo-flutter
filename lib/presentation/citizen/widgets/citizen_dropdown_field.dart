import 'package:flutter/material.dart';
import 'package:garbo_swms/core/theme/colors.dart';
import 'package:garbo_swms/core/theme/typography.dart';

/// Citizen form dropdown — keeps [DropdownButtonFormField] but styles the menu
/// to match the app input theme (green accents, white surface, rounded menu).
class CitizenDropdownField extends StatelessWidget {
  const CitizenDropdownField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.optional = false,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final menuItems = <DropdownMenuItem<String>>[
      if (optional)
        DropdownMenuItem<String>(
          value: null,
          child: _menuLabel('None', selected: value == null),
        ),
      ...options.map(
        (option) => DropdownMenuItem<String>(
          value: option,
          child: _menuLabel(option, selected: value == option),
        ),
      ),
    ];

    final selectedBuilders = <Widget>[
      if (optional)
        _selectedLabel('None'),
      ...options.map(_selectedLabel),
    ];

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: AppColors.surface,
        hoverColor: AppColors.greenSurface2,
        focusColor: AppColors.greenSurface2.withValues(alpha: 0.7),
        highlightColor: AppColors.greenSurface2.withValues(alpha: 0.5),
        splashColor: AppColors.green700.withValues(alpha: 0.12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 3,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.green700,
        ),
        style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
        decoration: InputDecoration(
          labelText: optional ? '$label (Optional)' : label,
          hintText: 'Select $label',
        ),
        isExpanded: true,
        items: menuItems,
        selectedItemBuilder: (_) => selectedBuilders,
        onChanged: onChanged,
      ),
    );
  }

  static Widget _menuLabel(String text, {required bool selected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: AppTypography.bodyMd.copyWith(
          color: selected ? AppColors.green700 : AppColors.grey900,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  static Widget _selectedLabel(String text) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        text,
        style: AppTypography.bodyMd.copyWith(color: AppColors.grey900),
      ),
    );
  }
}

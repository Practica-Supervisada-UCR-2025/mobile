import 'package:flutter/material.dart';

class ReportOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ReportOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(label),
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? theme.colorScheme.primary : theme.disabledColor,
      ),
      onTap: onTap,
    );
  }
}

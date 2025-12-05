import 'package:flutter/material.dart';

class FilterWidget extends StatelessWidget {
  final String field;
  final String label;
  final Map<String, bool> sortStatus;
  final void Function(String field) onSortChanged;
  const FilterWidget({
    super.key,
    required this.field,
    required this.label,
    required this.sortStatus,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = sortStatus.containsKey(field);
    final isAscending = sortStatus[field] ?? true;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            isActive && isAscending
                ? Icons.arrow_drop_up
                : Icons.arrow_drop_down,
            size: 16,
            color: isActive && isAscending
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: () => onSortChanged(field),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints.tightFor(width: 24, height: 24),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}

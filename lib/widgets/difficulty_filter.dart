import 'package:flutter/material.dart';

class DifficultyFilter extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const DifficultyFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selected,
      hint: const Text('Difficulté'),
      items: const [
        DropdownMenuItem(value: 'Easy', child: Text('Easy')),
        DropdownMenuItem(value: 'Medium', child: Text('Medium')),
        DropdownMenuItem(value: 'Hard', child: Text('Hard')),
      ],
      onChanged: onChanged,
    );
  }
}

import 'package:flutter/material.dart';

/// Chip selector — receives a plain List<String> snapshot.
/// The parent wraps it in Obx and passes .toList() so it rebuilds on change.
class IngredientSelector extends StatelessWidget {
  final List<String>     options;
  final List<String>     selectedItems;   // plain list, NOT RxList
  final Function(String) onToggle;
  final Color selectedColor;
  final Color selectedBorder;
  final Color selectedText;
  final Color unselectedColor;
  final Color unselectedText;

  const IngredientSelector({
    super.key,
    required this.options,
    required this.selectedItems,
    required this.onToggle,
    required this.selectedColor,
    required this.selectedBorder,
    required this.selectedText,
    this.unselectedColor = const Color(0xFF3D2069),
    this.unselectedText  = const Color(0xFFB39DDB),
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedItems.contains(option);
        return GestureDetector(
          onTap: () => onToggle(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? selectedColor : unselectedColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? selectedBorder : unselectedColor,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                color:      isSelected ? selectedText : unselectedText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize:   12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
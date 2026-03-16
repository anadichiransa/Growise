import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable chip selector for ingredient and preference selection.
///
/// Shows a wrap of tappable chips. Selected chips show a different
/// background/border color. Tapping toggles selection.
///
/// Used for:
///   - Liked foods (green tones)
///   - Disliked foods (red tones)
///   - Cooking methods (blue tones)
class IngredientSelector extends StatelessWidget {
  final List<String>     options;
  final RxList<String>   selectedItems;
  final Function(String) onToggle;
  final Color selectedColor;
  final Color selectedBorder;
  final Color selectedText;

  const IngredientSelector({
    super.key,
    required this.options,
    required this.selectedItems,
    required this.onToggle,
    required this.selectedColor,
    required this.selectedBorder,
    required this.selectedText,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selectedItems.contains(option);
        return GestureDetector(
          onTap: () => onToggle(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color:        isSelected ? selectedColor : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? selectedBorder : const Color(0xFFD1D5DB),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                color:      isSelected ? selectedText : const Color(0xFF4B5563),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize:   13,
              ),
            ),
          ),
        );
      }).toList(),
    ));
  }
}

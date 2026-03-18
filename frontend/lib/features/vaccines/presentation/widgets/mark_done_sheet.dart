
import 'package:flutter/material.dart';

class MarkDoneBottomSheet extends StatefulWidget {
  final String vaccineName;
  final Function(Map<String, dynamic>) onSubmit;

  const MarkDoneBottomSheet({super.key, required this.vaccineName, required this.onSubmit});

  @override
  State<MarkDoneBottomSheet> createState() => _MarkDoneBottomSheetState();
}

class _MarkDoneBottomSheetState extends State<MarkDoneBottomSheet> {
  final _clinicController = TextEditingController();
  final _batchController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A0E4E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Mark Done: ${widget.vaccineName}',
              style: const TextStyle(color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildLabel('Date Administered'),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF2D1B69),
                  borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(color: Colors.white)),
                  const Icon(Icons.calendar_today, color: Colors.white54, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildLabel('Clinic / PHM Name'),
          _buildTextField(_clinicController, 'e.g. Kalmunai MOH Clinic'),
          const SizedBox(height: 14),
          _buildLabel('Batch Number (Optional)'),
          _buildTextField(_batchController, 'e.g. BN-2024-001'),
          const SizedBox(height: 14),
          _buildLabel('Notes (Optional)'),
          _buildTextField(_notesController, 'Any additional info...', maxLines: 2),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E5CC),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Confirm & Save',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) =>
      TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: const Color(0xFF2D1B69),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
        ),
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    widget.onSubmit({
      'administered_date': _selectedDate.toIso8601String(),
      'administered_by': _clinicController.text,
      'batch_number': _batchController.text,
      'notes': _notesController.text,
    });
    Navigator.pop(context);
  }
}

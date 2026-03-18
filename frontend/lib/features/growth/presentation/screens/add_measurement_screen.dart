import 'package:flutter/material.dart';
import '../controllers/growth_controller.dart';
import 'package:growise/shared/widgets/common/bottom_nav.dart';

class AddMeasurementScreen extends StatefulWidget {
  final String childId;
  final String childName;
  final String gender;
  final DateTime dateOfBirth;

  const AddMeasurementScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.gender,
    required this.dateOfBirth,
  });

  @override
  State<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen> {
  final GrowthController _controller = GrowthController();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _measuredAt = 'home';
  bool _isSaving = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: widget.dateOfBirth,
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD9A577),
              onPrimary: Colors.black,
              surface: Color(0xFF3B1B45),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final weight = double.parse(_weightController.text.trim());
      final height = double.parse(_heightController.text.trim());

      final success = await _controller.addMeasurement(
        childId: widget.childId,
        childName: widget.childName,
        gender: widget.gender,
        dateOfBirth: widget.dateOfBirth,
        date: _selectedDate,
        weight: weight,
        height: height,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Measurement saved!'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save. Please try again.'),
            backgroundColor: Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B0B3B),
      bottomNavigationBar: AppBottomNav(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circularIconButton(Icons.arrow_back, Colors.white12, () {
                    Navigator.pop(context);
                  }),
                  const Text(
                    'Add Measurement',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 48), // balance the back button
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // Child name header
                      Text(
                        'Recording for ${widget.childName}',
                        style: const TextStyle(
                          color: Color(0xFFD9A577),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Date Picker
                      _sectionLabel('Measurement Date'),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B1B45),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              const Icon(Icons.calendar_today,
                                  color: Color(0xFFD9A577), size: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Weight
                      _sectionLabel('Weight (kg)'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: _weightController,
                        hint: 'e.g. 7.5',
                        icon: Icons.monitor_weight_outlined,
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Please enter weight';
                          final w = double.tryParse(val);
                          if (w == null || w <= 0)
                            return 'Enter a valid number';
                          if (w < 1 || w > 30)
                            return 'Weight seems unusual — please check';
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Height
                      _sectionLabel('Height (cm)'),
                      const SizedBox(height: 8),
                      _inputField(
                        controller: _heightController,
                        hint: 'e.g. 68',
                        icon: Icons.height,
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Please enter height';
                          final h = double.tryParse(val);
                          if (h == null || h <= 0)
                            return 'Enter a valid number';
                          if (h < 40 || h > 150)
                            return 'Height seems unusual — please check';
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Measured At
                      _sectionLabel('Measured At'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _radioOption(
                                'Home', 'home', Icons.home_outlined),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _radioOption('Clinic', 'clinic',
                                Icons.local_hospital_outlined),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Notes
                      _sectionLabel('Notes (optional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Any observations or context...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: const Color(0xFF3B1B45),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // WHO info box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9A577).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: const Color(0xFFD9A577).withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Color(0xFFD9A577), size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Measurements are analysed using WHO Child Growth Standards (2006)',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 62),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35)),
                          elevation: 8,
                          disabledBackgroundColor:
                              Colors.orange.withOpacity(0.4),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.black, strokeWidth: 2.5),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Save Measurement',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward),
                                ],
                              ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 16),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFFD9A577), size: 22),
        filled: true,
        fillColor: const Color(0xFF3B1B45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Color(0xFFFF7070)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD9A577), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }

  Widget _radioOption(String label, String value, IconData icon) {
    final selected = _measuredAt == value;
    return GestureDetector(
      onTap: () => setState(() => _measuredAt = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFD9A577).withOpacity(0.15)
              : const Color(0xFF3B1B45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFD9A577) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: selected ? const Color(0xFFD9A577) : Colors.white38,
                size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? const Color(0xFFD9A577) : Colors.white54,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circularIconButton(IconData icon, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

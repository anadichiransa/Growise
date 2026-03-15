import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../controllers/growth_controller.dart';

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
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController  = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String   _measuredAt   = 'home';
  bool     _isSaving     = false;

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
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColours.primaryGold,
            onPrimary: Colors.black,
            surface: AppColours.deepMagenta,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final weight  = double.parse(_weightController.text.trim());
      final height  = double.parse(_heightController.text.trim());
      final success = await _controller.addMeasurement(
        childId:     widget.childId,
        gender:      widget.gender,
        dateOfBirth: widget.dateOfBirth,
        date:        _selectedDate,
        weight:      weight,
        height:      height,
        measuredAt:  _measuredAt,
        notes: _notesController.text.trim().isEmpty
            ? null : _notesController.text.trim(),
      );
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Measurement saved!'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to save. Please try again.'),
          backgroundColor: Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: const Color(0xFFC62828),
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.background,
      body: SafeArea(
        child: Column(children: [
          // App bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconBtn(Icons.arrow_back, Colors.white12, () => Navigator.pop(context)),
                const Text('Add Measurement', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(width: 48),
              ],
            ),
          ),

          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(key: _formKey, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Recording for ${widget.childName}',
                    style: TextStyle(color: AppColours.primaryGold,
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),

                // Date picker
                _label('Measurement Date'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColours.deepMagenta,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Icon(Icons.calendar_today,
                            color: AppColours.primaryGold, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Weight
                _label('Weight (kg)'),
                const SizedBox(height: 8),
                _inputField(
                  controller: _weightController,
                  hint: 'e.g. 7.5',
                  icon: Icons.monitor_weight_outlined,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter weight';
                    final w = double.tryParse(val);
                    if (w == null || w <= 0) return 'Enter a valid number';
                    if (w < 1 || w > 30)    return 'Weight seems unusual';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Height
                _label('Height (cm)'),
                const SizedBox(height: 8),
                _inputField(
                  controller: _heightController,
                  hint: 'e.g. 68',
                  icon: Icons.height,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Please enter height';
                    final h = double.tryParse(val);
                    if (h == null || h <= 0) return 'Enter a valid number';
                    if (h < 40 || h > 150)   return 'Height seems unusual';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Measured at
                _label('Measured At'),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _radioOption('Home',   'home',   Icons.home_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _radioOption('Clinic', 'clinic', Icons.local_hospital_outlined)),
                ]),
                const SizedBox(height: 24),

                // Notes
                _label('Notes (optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Any observations...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: AppColours.deepMagenta,
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
                    color: AppColours.primaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColours.primaryGold.withOpacity(0.3)),
                  ),
                  child: const Row(children: [
                    Icon(Icons.info_outline, color: Color(0xFFD9A577), size: 18),
                    SizedBox(width: 10),
                    Expanded(child: Text(
                      'Measurements are analysed using WHO Child Growth Standards (2006)',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    )),
                  ]),
                ),
                const SizedBox(height: 32),

                // Save button
                ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 62),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35)),
                    disabledBackgroundColor: Colors.orange.withOpacity(0.4),
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Save Measurement',
                                style: TextStyle(fontSize: 18,
                                    fontWeight: FontWeight.w900)),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                ),
                const SizedBox(height: 30),
              ],
            )),
          )),
        ]),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(color: Colors.white70, fontSize: 14,
          fontWeight: FontWeight.w600));

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
        prefixIcon: Icon(icon, color: AppColours.primaryGold, size: 22),
        filled: true,
        fillColor: AppColours.deepMagenta,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        errorStyle: const TextStyle(color: Color(0xFFFF7070)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColours.primaryGold, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
              ? AppColours.primaryGold.withOpacity(0.15)
              : AppColours.deepMagenta,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColours.primaryGold : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon,
              color: selected ? AppColours.primaryGold : Colors.white38,
              size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(
              color: selected ? AppColours.primaryGold : Colors.white54,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
        ]),
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color bg, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      );
}
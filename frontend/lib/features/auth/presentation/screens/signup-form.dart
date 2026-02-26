import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const GrowiseApp());
}

class GrowiseApp extends StatelessWidget {
  const GrowiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Growise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF1E1335),
      ),
      home: const SignupFormScreen(),
    );
  }
}

class SignupFormScreen extends StatefulWidget {
  const SignupFormScreen({super.key});

  @override
  State<SignupFormScreen> createState() =>
      _SignupFormScreenState();
}

class _SignupFormScreenState
    extends State<SignupFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  
  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();
  
  String? _selectedGender;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    // Show custom dialog with auto-formatting instead of default date picker
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return _CustomDatePickerDialog(
          initialDate: _selectedDate ?? DateTime.now(),
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dayController.text = picked.day.toString().padLeft(2, '0');
        _monthController.text = picked.month.toString().padLeft(2, '0');
        _yearController.text = picked.year.toString();
      });
    }
  }

  Future<void> _openNativeDatePicker(BuildContext context) async {
    // Open Android/iOS native date picker
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE8B36A),
              onPrimary: Color(0xFF1E1335),
              surface: Color(0xFF2D1F4A),
              onSurface: Colors.white,
            ),
            textTheme: const TextTheme(
              headlineMedium: TextStyle(color: Colors.white),
              titleLarge: TextStyle(color: Colors.white),
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              labelLarge: TextStyle(color: Colors.white),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dayController.text = picked.day.toString().padLeft(2, '0');
        _monthController.text = picked.month.toString().padLeft(2, '0');
        _yearController.text = picked.year.toString();
      });
    }
  }

  void _validateDateFields() {
    if (_dayController.text.isEmpty || 
        _monthController.text.isEmpty || 
        _yearController.text.isEmpty) {
      return;
    }

    try {
      int day = int.parse(_dayController.text);
      int month = int.parse(_monthController.text);
      int year = int.parse(_yearController.text);

      // Validate ranges
      if (day < 1 || day > 31) {
        _showSnackBar('Day must be between 01 and 31');
        return;
      }

      if (month < 1 || month > 12) {
        _showSnackBar('Month must be between 01 and 12');
        return;
      }

      int currentYear = DateTime.now().year;
      if (year < 2000 || year > currentYear) {
        _showSnackBar('Year must be between 2000 and $currentYear');
        return;
      }

      // Try to create date
      DateTime parsedDate = DateTime(year, month, day);

      // Check if date is valid
      if (parsedDate.day != day || parsedDate.month != month || parsedDate.year != year) {
        _showSnackBar('Invalid date. Please check the day and month.');
        return;
      }

      // Check if date is in the future
      if (parsedDate.isAfter(DateTime.now())) {
        _showSnackBar('Date cannot be in the future');
        return;
      }

      // Valid date
      setState(() {
        _selectedDate = parsedDate;
      });
    } catch (e) {
      _showSnackBar('Please enter a valid date');
    }
  }

  void _completeSetup() {
    // Validate inputs
    if (_nameController.text.isEmpty) {
      _showSnackBar('Please enter child\'s name');
      return;
    }
    if (_dayController.text.isEmpty || _monthController.text.isEmpty || _yearController.text.isEmpty) {
      _showSnackBar('Please enter complete date of birth');
      return;
    }
    if (_selectedGender == null) {
      _showSnackBar('Please select gender');
      return;
    }

    // Validate date one more time
    _validateDateFields();
    
    if (_selectedDate == null) {
      _showSnackBar('Please enter a valid date');
      return;
    }

    // TODO: Save data to Firebase
    _showSnackBar('Setup completed successfully!');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2D1F4A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Back button and progress indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // TODO: Navigate back
                      },
                    ),
                    Row(
                      children: [
                        _buildProgressDot(false),
                        const SizedBox(width: 8),
                        _buildProgressDot(true),
                        const SizedBox(width: 8),
                        _buildProgressDot(false),
                      ],
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
                const SizedBox(height: 40),
                // Title
                const Text(
                  'Personalize Your\nExperience',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                const Text(
                  'Tell us a bit about your child so we can tailor the content specifically for their development stage.',
                  style: TextStyle(
                    color: Color(0xFFB8B0C8),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                // Child's Name Field
                _buildLabel('CHILD\'S NAME'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'e.g. Sahan',
                  prefixIcon: Icons.emoji_emotions_outlined,
                ),
                const SizedBox(height: 24),
                // Date of Birth Field
                _buildLabel('DATE OF BIRTH'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Day field
                    Expanded(
                      flex: 2,
                      child: _buildDateSegmentField(
                        controller: _dayController,
                        focusNode: _dayFocus,
                        hintText: 'DD',
                        maxLength: 2,
                        nextFocus: _monthFocus,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '/',
                        style: TextStyle(
                          color: Color(0xFF6B5A7F),
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    // Month field
                    Expanded(
                      flex: 2,
                      child: _buildDateSegmentField(
                        controller: _monthController,
                        focusNode: _monthFocus,
                        hintText: 'MM',
                        maxLength: 2,
                        nextFocus: _yearFocus,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '/',
                        style: TextStyle(
                          color: Color(0xFF6B5A7F),
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    // Year field
                    Expanded(
                      flex: 3,
                      child: _buildDateSegmentField(
                        controller: _yearController,
                        focusNode: _yearFocus,
                        hintText: 'YYYY',
                        maxLength: 4,
                        isLast: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Calendar picker button
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D1F4A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3D2F54),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.calendar_month,
                          color: Color(0xFFE8B36A),
                          size: 24,
                        ),
                        onPressed: () => _openNativeDatePicker(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Gender Selection
                _buildLabel('GENDER'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderButton(
                        label: 'Boy',
                        icon: Icons.male,
                        isSelected: _selectedGender == 'Boy',
                        onTap: () {
                          setState(() {
                            _selectedGender = 'Boy';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildGenderButton(
                        label: 'Girl',
                        icon: Icons.female,
                        isSelected: _selectedGender == 'Girl',
                        onTap: () {
                          setState(() {
                            _selectedGender = 'Girl';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Complete Setup Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _completeSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8B36A),
                      foregroundColor: const Color(0xFF1E1335),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Complete Setup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.check_circle_outline, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Skip for now
                Center(
                  child: TextButton(
                    onPressed: () {
                      // TODO: Skip setup
                    },
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        color: Color(0xFFB8B0C8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDot(bool isActive) {
    return Container(
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE8B36A) : const Color(0xFF4A3D5F),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFD4A574),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    int? maxLength,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2D1F4A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3D2F54),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        maxLength: maxLength,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: onChanged,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF6B5A7F),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: const Color(0xFF6B5A7F),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          counterText: '', // Hide character counter
        ),
      ),
    );
  }

  Widget _buildDateSegmentField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required int maxLength,
    FocusNode? nextFocus,
    bool isLast = false,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF2D1F4A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3D2F54),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        maxLength: maxLength,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF6B5A7F),
            fontSize: 16,
          ),
          border: InputBorder.none,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 16,
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxLength),
        ],
        onChanged: (value) {
          if (value.length == maxLength && !isLast && nextFocus != null) {
            // Auto-advance to next field
            FocusScope.of(context).requestFocus(nextFocus);
          }
          if (isLast || (value.length == maxLength && nextFocus == null)) {
            // Validate when last field is complete
            _validateDateFields();
          }
        },
      ),
    );
  }

  Widget _buildGenderButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A3667)
              : const Color(0xFF2D1F4A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5D4882)
                : const Color(0xFF3D2F54),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF6B5A7F),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF6B5A7F),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Date Picker Dialog with Auto-Formatting
class _CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const _CustomDatePickerDialog({
    required this.initialDate,
  });

  @override
  State<_CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}
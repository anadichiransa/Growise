import 'package:flutter/material.dart';

/// Data model representing a child profile entry in the Switch Profile row.
class ChildProfileSummary {
  final String id;
  final String name;
  final ImageProvider? avatar;

  const ChildProfileSummary({
    required this.id,
    required this.name,
    this.avatar,
  });
}

/// Payload returned when the user taps "Save Changes".
class ProfileFormData {
  final String fullName;
  final DateTime birthdate;
  final String gender;

  const ProfileFormData({
    required this.fullName,
    required this.birthdate,
    required this.gender,
  });
}

/// A reusable screen for viewing and editing a single child profile.
///
/// Usage:
/// ```dart
/// ProfileScreen(
///   initialName: profile.name,
///   initialBirthdate: profile.birthdate,
///   initialGender: profile.gender,
///   avatarImage: NetworkImage(profile.avatarUrl),
///   lastWeightCheckLabel: '2 days ago',
///   profiles: summaryList,
///   selectedProfileId: profile.id,
///   genderOptions: const ['Male', 'Female', 'Other'],
///   onSave: (data) => ref.read(profileProvider.notifier).save(data),
///   onAvatarTap: () => _pickImage(),
///   onAddProfile: () => context.push('/add-profile'),
///   onSwitchProfile: (id) => ref.read(profileProvider.notifier).switchTo(id),
///   onViewAll: () => context.push('/profiles'),
///   onBack: () => context.pop(),
/// )
/// ```
class ProfileScreen extends StatefulWidget {
  // ── Required fields ──────────────────────────────────────────────────────

  /// Initial value for the full name field.
  final String initialName;

  /// Initial birthdate shown in the date field.
  final DateTime initialBirthdate;

  /// Initial selected gender. Must be one of [genderOptions].
  final String initialGender;

  /// Called when the user taps "Save Changes".
  /// Receives the current form values as [ProfileFormData].
  final Future<void> Function(ProfileFormData data) onSave;

  // ── Optional display ─────────────────────────────────────────────────────

  /// Avatar image for the main profile. Defaults to a placeholder icon.
  final ImageProvider? avatarImage;

  /// Text shown below the profile name, e.g. "Last weight check: 2 days ago".
  /// Pass null to hide the label entirely.
  final String? lastWeightCheckLabel;

  /// List of available gender options rendered as toggle chips.
  /// Defaults to ['Male', 'Female', 'Other'].
  final List<String> genderOptions;

  // ── Switch Profile row ───────────────────────────────────────────────────

  /// Profiles shown in the Switch Profile row.
  /// Pass an empty list to hide the section entirely.
  final List<ChildProfileSummary> profiles;

  /// The id of the currently active profile (highlighted in the row).
  final String? selectedProfileId;

  /// Called when the user taps a profile chip in the Switch Profile row.
  final void Function(String profileId)? onSwitchProfile;

  /// Called when the user taps "View All".
  final VoidCallback? onViewAll;

  /// Called when the user taps the "+" add profile button.
  final VoidCallback? onAddProfile;

  // ── Navigation callbacks ─────────────────────────────────────────────────

  /// Called when the user taps the back arrow. Defaults to [Navigator.maybePop].
  final VoidCallback? onBack;

  /// Called when the user taps the overflow (⋮) menu icon.
  final VoidCallback? onMenuTap;

  /// Called when the user taps the avatar / camera icon.
  final VoidCallback? onAvatarTap;

  const ProfileScreen({
    super.key,
    required this.initialName,
    required this.initialBirthdate,
    required this.initialGender,
    required this.onSave,
    this.avatarImage,
    this.lastWeightCheckLabel,
    this.genderOptions = const ['Male', 'Female', 'Other'],
    this.profiles = const [],
    this.selectedProfileId,
    this.onSwitchProfile,
    this.onViewAll,
    this.onAddProfile,
    this.onBack,
    this.onMenuTap,
    this.onAvatarTap,
  }) : assert(genderOptions.length > 0, 'genderOptions must not be empty');

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late DateTime _selectedDate;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedDate = widget.initialBirthdate;
    _selectedGender = widget.initialGender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    await widget.onSave(
      ProfileFormData(
        fullName: _nameController.text.trim(),
        birthdate: _selectedDate,
        gender: _selectedGender,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.dark(
            primary: _ProfileScreenTheme.accent,
            onPrimary: _ProfileScreenTheme.bgDark,
            surface: _ProfileScreenTheme.cardBg,
            onSurface: _ProfileScreenTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime d) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ProfileScreenTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(
                onBack: widget.onBack ?? () => Navigator.maybePop(context),
                onMenu: widget.onMenuTap,
              ),
              _AvatarSection(
                image: widget.avatarImage,
                name: _nameController.text,
                gender: _selectedGender,
                lastWeightCheckLabel: widget.lastWeightCheckLabel,
                onAvatarTap: widget.onAvatarTap,
              ),
              const SizedBox(height: 28),
              _FormCard(
                nameController: _nameController,
                formattedDate: _formatDate(_selectedDate),
                onDateTap: _pickDate,
                selectedGender: _selectedGender,
                genderOptions: widget.genderOptions,
                onGenderChanged: (g) => setState(() => _selectedGender = g),
                onSave: _handleSave,
              ),
              if (widget.profiles.isNotEmpty) ...[
                const SizedBox(height: 28),
                _SwitchProfileSection(
                  profiles: widget.profiles,
                  selectedProfileId: widget.selectedProfileId,
                  onSwitchProfile: widget.onSwitchProfile,
                  onViewAll: widget.onViewAll,
                  onAddProfile: widget.onAddProfile,
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Private sub-widgets
// ════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onMenu;

  const _TopBar({required this.onBack, this.onMenu});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          const Expanded(
            child: Text(
              'Child Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ProfileScreenTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _CircleIconButton(
            icon: Icons.more_vert_rounded,
            onTap: onMenu ?? () {},
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _ProfileScreenTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: _ProfileScreenTheme.textPrimary, size: 18),
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final ImageProvider? image;
  final String name;
  final String? lastWeightCheckLabel;
  final VoidCallback? onAvatarTap;
  final String gender;

  const _AvatarSection({
    required this.name,
    required this.gender,
    this.image,
    this.lastWeightCheckLabel,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGirl =
        gender.toLowerCase() == 'girl' || gender.toLowerCase() == 'female';
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: _ProfileScreenTheme.accent, width: 3),
            color: _ProfileScreenTheme.cardBg,
          ),
          child: Icon(
            isGirl ? Icons.face_2 : Icons.face,
            size: 52,
            color: _ProfileScreenTheme.accent,
          ),
        ),
        const SizedBox(height: 12),
        Text(name,
            style: const TextStyle(
                color: _ProfileScreenTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        if (lastWeightCheckLabel != null) ...[
          const SizedBox(height: 4),
          Text('Last weight check: $lastWeightCheckLabel',
              style: const TextStyle(
                  color: _ProfileScreenTheme.textSecondary, fontSize: 12.5)),
        ],
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final TextEditingController nameController;
  final String formattedDate;
  final VoidCallback onDateTap;
  final String selectedGender;
  final List<String> genderOptions;
  final void Function(String) onGenderChanged;
  final Future<void> Function() onSave;

  const _FormCard({
    required this.nameController,
    required this.formattedDate,
    required this.onDateTap,
    required this.selectedGender,
    required this.genderOptions,
    required this.onGenderChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _ProfileScreenTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('FULL NAME'),
          const SizedBox(height: 8),
          _InputField(controller: nameController),
          const SizedBox(height: 20),
          const _FieldLabel('BIRTHDATE'),
          const SizedBox(height: 8),
          _DateField(label: formattedDate, onTap: onDateTap),
          const SizedBox(height: 20),
          const _FieldLabel('GENDER'),
          const SizedBox(height: 10),
          _GenderToggle(
            options: genderOptions,
            selected: selectedGender,
            onChanged: onGenderChanged,
          ),
          const SizedBox(height: 24),
          _SaveButton(onTap: onSave),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _ProfileScreenTheme.accent,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  const _InputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: _ProfileScreenTheme.textPrimary,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: _ProfileScreenTheme.inputBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _ProfileScreenTheme.inputBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _ProfileScreenTheme.textPrimary,
                fontSize: 15,
              ),
            ),
            const Icon(
              Icons.calendar_today_rounded,
              color: _ProfileScreenTheme.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderToggle extends StatelessWidget {
  final List<String> options;
  final String selected;
  final void Function(String) onChanged;

  const _GenderToggle({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selected == option;
        return GestureDetector(
          onTap: () => onChanged(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
            decoration: BoxDecoration(
              color: isSelected
                  ? _ProfileScreenTheme.accent
                  : _ProfileScreenTheme.inputBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected
                    ? _ProfileScreenTheme.bgDark
                    : _ProfileScreenTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final Future<void> Function() onTap;
  const _SaveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _ProfileScreenTheme.accent,
          foregroundColor: _ProfileScreenTheme.bgDark,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Save Changes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _SwitchProfileSection extends StatelessWidget {
  final List<ChildProfileSummary> profiles;
  final String? selectedProfileId;
  final void Function(String)? onSwitchProfile;
  final VoidCallback? onViewAll;
  final VoidCallback? onAddProfile;

  const _SwitchProfileSection({
    required this.profiles,
    this.selectedProfileId,
    this.onSwitchProfile,
    this.onViewAll,
    this.onAddProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Switch Profile',
                style: TextStyle(
                  color: _ProfileScreenTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: _ProfileScreenTheme.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...profiles.map(
                  (p) => _ProfileChip(
                    profile: p,
                    isSelected: p.id == selectedProfileId,
                    onTap: () => onSwitchProfile?.call(p.id),
                  ),
                ),
                if (onAddProfile != null) _AddProfileChip(onTap: onAddProfile!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final ChildProfileSummary profile;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProfileChip({
    required this.profile,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? _ProfileScreenTheme.accent
                      : Colors.transparent,
                  width: 2.5,
                ),
                color: _ProfileScreenTheme.cardBg,
                image: profile.avatar != null
                    ? DecorationImage(image: profile.avatar!, fit: BoxFit.cover)
                    : null,
              ),
              child: profile.avatar == null
                  ? const Icon(
                      Icons.person,
                      size: 28,
                      color: _ProfileScreenTheme.textSecondary,
                    )
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              profile.name,
              style: TextStyle(
                color: isSelected
                    ? _ProfileScreenTheme.accent
                    : _ProfileScreenTheme.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddProfileChip extends StatelessWidget {
  final VoidCallback onTap;
  const _AddProfileChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _ProfileScreenTheme.accent, width: 2),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: _ProfileScreenTheme.accent,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add',
            style: TextStyle(
              color: _ProfileScreenTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Theme constants (private — not exposed globally)
// ════════════════════════════════════════════════════════════════════════════
abstract class _ProfileScreenTheme {
  static const bgDark = Color(0xFF1A0E2E);
  static const cardBg = Color(0xFF2A1A42);
  static const inputBg = Color(0xFF3A2A52);
  static const accent = Color(0xFFD4A96A);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFAA99BB);
}

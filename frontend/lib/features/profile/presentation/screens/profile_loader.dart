import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:growise/shared/services/child_service.dart';
import 'package:growise/features/profile/presentation/screens/profile_screen.dart';

class ProfileLoader extends StatefulWidget {
  const ProfileLoader({super.key});

  @override
  State<ProfileLoader> createState() => _ProfileLoaderState();
}

class _ProfileLoaderState extends State<ProfileLoader> {
  Map<String, dynamic>? _child;
  List<Map<String, dynamic>> _allChildren = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final first = await ChildService.getFirstChild();
    final all = await ChildService.getAllChildren();
    if (mounted) {
      setState(() {
        _child = first;
        _allChildren = all;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A0E2E),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4A96A)),
        ),
      );
    }

    if (_child == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A0E2E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.child_care, color: Color(0xFFD4A96A), size: 60),
              const SizedBox(height: 16),
              const Text('No child profile found',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.toNamed('/signup-form'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4A96A),
                  foregroundColor: const Color(0xFF1A0E2E),
                ),
                child: const Text('Add Child Profile'),
              ),
            ],
          ),
        ),
      );
    }

    final birthDate = _child!['birthDate'] != null
        ? (_child!['birthDate'] as dynamic).toDate()
        : DateTime(2022, 1, 1);

    final gender = _child!['gender'] ?? 'Boy';

    // Build switch profile list from all children
    final profiles = _allChildren
        .map((c) => ChildProfileSummary(
              id: c['id'],
              name: c['name'] ?? '',
            ))
        .toList();

    return ProfileScreen(
      initialName: _child!['name'] ?? '',
      initialBirthdate: birthDate,
      initialGender: gender,
      genderOptions: const ['Boy', 'Girl'],
      profiles: profiles,
      selectedProfileId: _child!['id'],
      onBack: () => Get.back(),
      onAddProfile: () => Get.toNamed('/signup-form'),
      onSwitchProfile: (profileId) async {
        // ← ADD THIS
        final selected = _allChildren.firstWhere(
          (c) => c['id'] == profileId,
          orElse: () => {},
        );
        if (selected.isNotEmpty && mounted) {
          setState(() {
            _child = selected;
            _loading = false;
          });
        }
      },
      onSave: (data) async {
        final success = await ChildService.updateChild(
          childId: _child!['id'],
          name: data.fullName,
          birthDate: data.birthdate,
          gender: data.gender,
        );
        if (success) {
          Get.snackbar(
            'Saved',
            'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF26D07C).withOpacity(0.9),
            colorText: Colors.white,
          );
          Get.back();
        } else {
          Get.snackbar(
            'Error',
            'Failed to save. Try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.9),
            colorText: Colors.white,
          );
        }
      },
    );
  }
}

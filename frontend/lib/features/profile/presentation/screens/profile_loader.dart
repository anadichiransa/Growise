import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:growise/features/profile/presentation/controllers/child_controller.dart';
import 'package:growise/features/profile/presentation/screens/profile_screen.dart';

class ProfileLoader extends StatefulWidget {
  const ProfileLoader({super.key});

  @override
  State<ProfileLoader> createState() => _ProfileLoaderState();
}

class _ProfileLoaderState extends State<ProfileLoader> {
  @override
  void initState() {
    super.initState();
    // Refresh data every time profile page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ChildController>().loadChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChildController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          backgroundColor: Color(0xFF1A0E2E),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFD4A96A)),
          ),
        );
      }

      if (controller.child == null) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A0E2E),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.child_care,
                  color: Color(0xFFD4A96A),
                  size: 60,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No child profile found',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
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

      final child = controller.child!;
      DateTime birthDate;
      try {
        final raw = child['birthDate'];
        if (raw == null) {
          birthDate = DateTime(2022, 1, 1);
        } else if (raw is DateTime) {
          birthDate = raw;
        } else {
          birthDate = raw.toDate();
        }
      } catch (e) {
        birthDate = DateTime(2022, 1, 1);
      }

      final profiles = controller.allChildren
          .map((c) => ChildProfileSummary(id: c['id'], name: c['name'] ?? ''))
          .toList();

      return ProfileScreen(
        key: ValueKey(child['id']),
        initialName: child['name'] ?? '',
        initialBirthdate: birthDate,
        initialGender: child['gender'] ?? 'Boy',
        genderOptions: const ['Boy', 'Girl'],
        profiles: profiles,
        selectedProfileId: child['id'],
        onBack: () => Navigator.of(context).pop(),
        onAddProfile: () => Get.toNamed('/signup-form'),
        onSwitchProfile: (profileId) => controller.switchChild(profileId),
        onSave: (data) async {
          final success = await controller.updateCurrentChild(
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
            Navigator.of(context).pop();
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
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:growise/features/profile/presentation/controllers/child_controller.dart';
import 'package:growise/shared/widgets/common/bottom_nav.dart';

class BabyTrackerHome extends StatefulWidget {
  const BabyTrackerHome({super.key});

  @override
  State<BabyTrackerHome> createState() => _BabyTrackerHomeState();
}

class _BabyTrackerHomeState extends State<BabyTrackerHome> {
  @override
  void initState() {
    super.initState();
    // Refresh child data when dashboard opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ChildController>().loadChildren();
    });
  }
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140824),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Obx(() {
                    final isGirl =
                        Get.find<ChildController>().childGender.toLowerCase() ==
                        'girl';
                    return GestureDetector(
                      onTap: () => Get.toNamed('/profile'),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF2A1245),
                        child: Icon(
                          isGirl ? Icons.face_2 : Icons.face,
                          color: const Color(0xFFF6A960),
                          size: 26,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome Back,",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(
                          () => Text(
                            Get.find<ChildController>().childName,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed('/notification'),
                    child: _buildIconButton(Icons.notifications_none),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ---------------- BODY ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    /// STATUS SUMMARY CARD
                    _buildStatusCard(),

                    const SizedBox(height: 24),

                    /// MODULE GRID (The Core Features)
                    Row(
                      children: [
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.bar_chart_rounded,
                            title: "Growth\nMonitoring",
                            subtitle: "WHO Standards",
                            onTap: () => Get.toNamed('/growth'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.vaccines_outlined,
                            title: "Vaccination\nSchedule",
                            subtitle: "Due Reminders",
                            onTap: () => Get.toNamed('/vaccines'),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.restaurant_menu,
                            title: "Meal Planner",
                            subtitle: "Nutrition AI",
                            onTap: () => Get.toNamed('/meals'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.school_outlined,
                            title: "Education Hub",
                            subtitle: "Child Milestones",
                            onTap: () => Get.toNamed('/education'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// ---------------- NAVIGATION ----------------
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  /// UI Helper: Generic Status Card
  Widget _buildStatusCard() {
    final controller = Get.find<ChildController>();
    return Obx(() {
      final child = controller.child;
      final name = controller.childName;
      final gender = controller.childGender;

      // Calculate age
      String ageText = '';
      String tip = '';
      if (child != null && child['birthDate'] != null) {
        try {
          final birthDate =
              (child['birthDate'] as dynamic).toDate() as DateTime;
          final now = DateTime.now();
          final months =
              (now.year - birthDate.year) * 12 + now.month - birthDate.month;
          if (months < 12) {
            ageText = '$months months old';
          } else {
            final years = months ~/ 12;
            final rem = months % 12;
            ageText = rem > 0 ? '$years yr $rem mo old' : '$years years old';
          }

          // Age-based tip
          if (months < 6) {
            tip = 'Breast milk is the best nutrition at this stage.';
          } else if (months < 12) {
            tip = 'Time to start exploring solid foods!';
          } else if (months < 24) {
            tip = 'Encourage walking and talking every day.';
          } else if (months < 36) {
            tip = 'Reading together boosts language development.';
          } else {
            tip = 'Active play supports healthy growth.';
          }
        } catch (_) {
          ageText = '';
          tip = 'Keep tracking growth and vaccinations.';
        }
      } else {
        tip = 'Add your child\'s details to get personalised tips.';
      }

      final isGirl = gender.toLowerCase() == 'girl';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E0E34),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF6D4C9C).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HEALTH SUMMARY',
                    style: TextStyle(
                      color: Color(0xFFF6A960),
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$name\nis doing great!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  if (ageText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      ageText,
                      style: const TextStyle(
                        color: Color(0xFF26D07C),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 ', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF2A1245),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF6A960), width: 2),
              ),
              child: Icon(
                isGirl ? Icons.face_2 : Icons.face,
                size: 36,
                color: const Color(0xFFF6A960),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2A1245),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

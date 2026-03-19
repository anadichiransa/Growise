import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get.dart';
import 'package:growise/features/profile/presentation/controllers/child_controller.dart';

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

            /// ---------------- HEADER (Generic) ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed('/profile'),
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundColor: Color(0xFF2A1245),
                      child: Icon(Icons.person_outline, color: Colors.white),
                    ),
                  ),
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
                  _buildIconButton(Icons.notifications_none),
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
                            onTap: () => Get.toNamed('/activity'),
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// UI Helper: Generic Status Card
  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0E34),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF6D4C9C).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "HEALTH SUMMARY",
            style: TextStyle(
              color: Color(0xFFF6A960),
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Condition:\nStable",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "System Status:",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const Text(
            "Waiting for data input...",
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
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

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: const Color(0xFF140824),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_filled, label: "Home", active: true),
          _NavItem(icon: Icons.show_chart, label: "Tracker", active: false),
          _NavItem(icon: Icons.school_outlined, label: "Learn", active: false),
          _NavItem(
            icon: Icons.settings_outlined,
            label: "Settings",
            active: false,
          ),
        ],
      ),
    );
  }
}

/// Helper Widget: Feature Card (Reusable Component)
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E0E34),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0x2226D07C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFF6A960), size: 20),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? const Color(0xFF26D07C) : Colors.white54),
        Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF26D07C) : Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

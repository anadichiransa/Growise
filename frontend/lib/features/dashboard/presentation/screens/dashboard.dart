// frontend/lib/features/dashboard/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/feature_card.dart';
import '../widgets/offline_status_banner.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFF140824),
      body: SafeArea(
        child: Column(
          children: [
            const OfflineStatusBanner(),
            const SizedBox(height: 10),

            // ── Header ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Avatar — network url if set, else local asset
                  Obx(() {
                    final avatarUrl = controller.userAvatar.value;
                    return CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF2A1245),
                      backgroundImage: avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : const AssetImage(
                                  'assets/images/avatar_default.jpeg',
                                )
                                as ImageProvider,
                    );
                  }),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Good Morning,',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        // ── Dynamic name from profile API ─────────
                        Obx(
                          () => Text(
                            controller.userName.value,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1245),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ── Scrollable body ─────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFF26D07C),
                backgroundColor: const Color(0xFF1E0E34),
                onRefresh: controller.refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // ── Quick Overview card ──────────────────
                      Obx(() {
                        if (controller.isLoading.value) {
                          return const SizedBox(
                            height: 140,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF26D07C),
                              ),
                            ),
                          );
                        }

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E0E34),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: const Color(0xFF6D4C9C).withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'QUICK OVERVIEW',
                                    style: TextStyle(
                                      color: Color(0xFFF6A960),
                                      fontSize: 11,
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0x3326D07C),
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Color(0xFF26D07C),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                '${controller.childName.value} is doing great!',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Latest update:',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.latestUpdate.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 24),

                      // ── Feature grid ─────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: FeatureCard(
                              icon: Icons.bar_chart_rounded,
                              title: 'Growth\nMonitoring',
                              subtitle: 'Track height & weight',
                              onTap: controller.goToGrowth,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FeatureCard(
                              icon: Icons.vaccines_outlined,
                              title: 'Vaccination\nSchedule',
                              subtitle: 'Next: See schedule',
                              onTap: controller.goToVaccination,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FeatureCard(
                              icon: Icons.restaurant_menu,
                              title: 'Meal Planner',
                              subtitle: 'Daily nutrition guide',
                              onTap: controller.goToMeals,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FeatureCard(
                              icon: Icons.school_outlined,
                              title: 'Education Hub',
                              subtitle: 'Development tips',
                              onTap: controller.goToEducation,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom nav ────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(color: Color(0xFF140824)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              label: 'Home',
              active: true,
              onTap: () {},
            ),
            _NavItem(
              icon: Icons.show_chart,
              label: 'Tracker',
              active: false,
              onTap: controller.goToGrowth,
            ),
            _NavItem(
              icon: Icons.school_outlined,
              label: 'Education',
              active: false,
              onTap: controller.goToEducation,
            ),
            _NavItem(
              icon: Icons.support_agent_outlined,
              label: 'Support',
              active: false,
              onTap: () {
                Get.snackbar(
                  'Coming Soon',
                  'Support feature is under development',
                  backgroundColor: const Color(0xFF1E0E34),
                  colorText: Colors.white,
                );
              },
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
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF26D07C) : Colors.white54),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF26D07C) : Colors.white54,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

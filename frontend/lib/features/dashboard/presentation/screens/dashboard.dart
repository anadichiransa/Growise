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

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BabyTrackerHome(),
    );
  }
}

class BabyTrackerHome extends StatelessWidget {
  const BabyTrackerHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140824), // darker background
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// ---------------- HEADER ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF2A1245),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Good Morning,",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Amara Perera",
                          style: TextStyle(color: Colors.white60, fontSize: 13),
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

            /// ---------------- BODY ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    /// QUICK OVERVIEW CARD
                    Container(
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "QUICK OVERVIEW",
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

                          const Text(
                            "Sahan is doing\ngreat!",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            "Latest update:",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            "Height & Weight recorded today",
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// FEATURE GRID
                    Row(
                      children: [
                        Expanded(
                          child: buildFeatureCard(
                            icon: Icons.bar_chart_rounded,
                            title: "Growth\nMonitoring",
                            subtitle: "Track height & weight",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: buildFeatureCard(
                            icon: Icons.vaccines_outlined,
                            title: "Vaccination\nSchedule",
                            subtitle: "Next: Polio (Oct 12)",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: buildFeatureCard(
                            icon: Icons.restaurant_menu,
                            title: "Meal Planner",
                            subtitle: "Daily nutrition guide",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: buildFeatureCard(
                            icon: Icons.school_outlined,
                            title: "Education Hub",
                            subtitle: "Development tips",
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

      /// ---------------- BOTTOM NAV ----------------
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(color: Color(0xFF140824)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            NavItem(icon: Icons.home_outlined, label: "Home", active: false),
            NavItem(icon: Icons.show_chart, label: "Tracker", active: true),
            NavItem(
              icon: Icons.school_outlined,
              label: "Education",
              active: false,
            ),
            NavItem(
              icon: Icons.support_agent_outlined,
              label: "Support",
              active: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
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
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: const Color(0x3326D07C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFF6A960)),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const NavItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.active,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? Color(0xFF26D07C) : Colors.white54),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Color(0xFF26D07C) : Colors.white54,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

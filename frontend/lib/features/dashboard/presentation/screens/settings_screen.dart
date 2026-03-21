import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140824),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── ACCOUNT MANAGEMENT ──────────────────────
                    const Text(
                      'ACCOUNT MANAGEMENT',
                      style: TextStyle(
                        color: Color(0xFFD4A96A),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSection([
                      _SettingsItem(
                        icon: Icons.person_outline,
                        label: 'Edit Profile',
                        onTap: () => Get.toNamed('/profile'),
                      ),
                      _SettingsItem(
                        icon: Icons.shield_outlined,
                        label: 'Access Requests',
                        onTap: () => Get.toNamed('/access-requesting'),
                      ),
                    ]),

                    const SizedBox(height: 32),

                    // ── SUPPORT & SAFETY ─────────────────────────
                    const Text(
                      'SUPPORT & SAFETY',
                      style: TextStyle(
                        color: Color(0xFFD4A96A),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSection([
                      _SettingsItem(
                        icon: Icons.lock_reset_outlined,
                        label: 'Help & Recovery',
                        onTap: () => Get.toNamed('/help'),
                      ),
                      _SettingsItem(
                        icon: Icons.headset_mic_outlined,
                        label: 'Support Center',
                        onTap: () => Get.toNamed('/support'),
                      ),
                    ]),

                    const Spacer(),

                    // ── LOGOUT ───────────────────────────────────
                    GestureDetector(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.offAllNamed('/');
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E0E34),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF6D4C9C).withOpacity(0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              color: Color(0xFFD4A96A),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(
                                color: Color(0xFFD4A96A),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(List<_SettingsItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E0E34),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF6D4C9C).withOpacity(0.3)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1245),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: const Color(0xFFD4A96A),
                    size: 18,
                  ),
                ),
                title: Text(
                  item.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Colors.white38,
                  size: 20,
                ),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                const Divider(
                  height: 1,
                  color: Color(0xFF2A1245),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

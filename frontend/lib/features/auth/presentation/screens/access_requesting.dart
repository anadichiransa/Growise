import 'package:flutter/material.dart';

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
      theme: ThemeData(useMaterial3: true),
      home: const SetupExperienceScreen(),
    );
  }
}
class SetupExperienceScreen extends StatelessWidget {
  const SetupExperienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0828), // deep purple-black at top
              Color(0xFF2D0D45), // medium deep purple mid
              Color(0xFF1C0A30), // dark purple-black at bottom
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative swirl lines (top-right corner) ──
            Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                width: 200,
                height: 260,
                child: CustomPaint(painter: _SwirlPainter()),
              ),
            ),

            // ── Back chevron (top-left) ──
            Positioned(
              top: 46,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: Colors.white54, size: 28),
                onPressed: () => Navigator.maybePop(context),
              ),
            ),

            // ── Main scrollable content ──
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 44),

                    // Title
                    const Text(
                      'Set Up Your\nExperience',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Subtitle
                    const Text(
                      'To provide the best care and record-keeping, we\nneed access to a few features on your device.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13.5,
                        height: 1.55,
                      ),
                    ),

                    const SizedBox(height: 38),

                    // ── Permission Cards ──
                    const _PermissionCard(
                      icon: Icons.folder_outlined,
                      title: 'Storage',
                      description:
                          'To save and retrieve offline documents\nand reports.',
                    ),

                    const SizedBox(height: 14),

                    const _PermissionCard(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      description:
                          'To receive urgent alerts regarding\ncase updates or approvals.',
                    ),

                    const SizedBox(height: 14),

                    const _PermissionCard(
                      icon: Icons.camera_alt_outlined,
                      title: 'Camera Access',
                      description:
                          'To capture and upload photos for\nchild identification records.',
                    ),

                    const Spacer(),

                    // ── Grant Access Button ──
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: request permissions
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8A44A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Grant Access',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Skip for now ──
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: skip to next screen
                        },
                        child: const Text(
                          'Skip for now',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
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
}

// ─────────────────────────────────────────────
// Reusable permission card
// ─────────────────────────────────────────────
class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        // Slightly lighter purple card background
        color: const Color(0xFF2A0E42).withOpacity(0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Orange-brown icon box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFB85C2A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),

          const SizedBox(width: 14),

          // Title + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

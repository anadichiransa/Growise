import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'features/dashboard/presentation/controllers/permission_controller.dart';

void main() {
  runApp(const GrowiseApp());
}

class GrowiseApp extends StatelessWidget {
  const GrowiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
    final controller = Get.put(PermissionController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0828),
              Color(0xFF2D0D45),
              Color(0xFF1C0A30),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: SizedBox(
                width: 200,
                height: 260,
                child: CustomPaint(painter: _SwirlPainter()),
              ),
            ),
            Positioned(
              top: 46,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: Colors.white54, size: 28),
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 44),
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
                    const Text(
                      'To provide the best care and record-keeping, we\nneed access to a few features on your device.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 13.5,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 38),

                    Obx(() => _PermissionCard(
                          icon: Icons.folder_outlined,
                          title: 'Storage',
                          description:
                              'To save and retrieve offline documents\nand reports.',
                          isGranted: controller.storageGranted.value,
                          onTap: () async {
                            final status = await Permission.photos.status;
                            if (status.isPermanentlyDenied) {
                              controller.openSettings();
                            } else {
                              await controller.requestStorage();
                            }
                          },
                        )),

                    const SizedBox(height: 14),

                    Obx(() => _PermissionCard(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          description:
                              'To receive urgent alerts regarding\ncase updates or approvals.',
                          isGranted: controller.notificationGranted.value,
                          onTap: () async {
                            final status =
                                await Permission.notification.status;
                            if (status.isPermanentlyDenied) {
                              controller.openSettings();
                            } else {
                              await controller.requestNotifications();
                            }
                          },
                        )),

                    const SizedBox(height: 14),

                    Obx(() => _PermissionCard(
                          icon: Icons.camera_alt_outlined,
                          title: 'Camera Access',
                          description:
                              'To capture and upload photos for\nchild identification records.',
                          isGranted: controller.cameraGranted.value,
                          onTap: () async {
                            final status = await Permission.camera.status;
                            if (status.isPermanentlyDenied) {
                              controller.openSettings();
                            } else {
                              await controller.requestCamera();
                            }
                          },
                        )),

                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller.requestAllPermissions();
                          if (controller.allGranted) {
                            // TODO: Get.toNamed('/dashboard');
                          }
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

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Get.toNamed('/dashboard');
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

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onTap;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A0E42).withOpacity(0.90),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGranted
                ? Colors.green.withOpacity(0.6)
                : Colors.white.withOpacity(0.07),
            width: isGranted ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isGranted
                    ? Colors.green[700]
                    : const Color(0xFFB85C2A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isGranted ? Icons.check : icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
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
                    isGranted ? 'Permission granted ✓' : description,
                    style: TextStyle(
                      color: isGranted
                          ? Colors.green[300]
                          : Colors.white54,
                      fontSize: 12.5,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwirlPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFF9B4FBF).withOpacity(0.55),
      const Color(0xFFB565D8).withOpacity(0.45),
      const Color(0xFF7E3AA0).withOpacity(0.50),
      const Color(0xFFC070E0).withOpacity(0.35),
      const Color(0xFF6B2E8F).withOpacity(0.40),
      const Color(0xFFD885F0).withOpacity(0.28),
    ];
    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..color = colors[i];
      _drawCurve(canvas, size, paint, i.toDouble());
    }
  }

  void _drawCurve(
      Canvas canvas, Size size, Paint paint, double offset) {
    final path = Path();
    final sx = size.width * (0.15 + offset * 0.13);
    const sy = 10.0;
    path.moveTo(sx, sy);
    path.cubicTo(
      sx + 55 + offset * 5,
      sy + 35,
      sx + 15 + offset * 3,
      sy + 90 + offset * 8,
      sx - 25 + offset * 2,
      sy + 140 + offset * 10,
    );
    path.cubicTo(
      sx - 55 + offset * 3,
      sy + 175 + offset * 5,
      sx + 25 + offset * 4,
      sy + 210 + offset * 6,
      sx + 5 + offset * 2,
      sy + 245 + offset * 3,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

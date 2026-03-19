// frontend/lib/features/dashboard/presentation/widgets/feature_card.dart

import 'package:flutter/material.dart';

/// A tappable card used in the dashboard feature grid.
///
/// Usage:
/// ```dart
/// FeatureCard(
///   icon: Icons.bar_chart_rounded,
///   title: 'Growth\nMonitoring',
///   subtitle: 'Track height & weight',
///   onTap: controller.goToGrowth,
/// )
/// ```
class FeatureCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  }) : super(key: key);

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1E0E34),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF6D4C9C).withOpacity(0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Icon Badge ────────────────────────────────
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF5A1E63).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: const Color(0xFFF6A960),
                  size: 22,
                ),
              ),

              const SizedBox(height: 16),

              // ── Title ─────────────────────────────────────
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 6),

              // ── Subtitle ──────────────────────────────────
              Text(
                widget.subtitle,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

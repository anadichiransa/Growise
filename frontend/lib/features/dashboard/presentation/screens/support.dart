import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.cardSurface,
        ),
      ),
      home: const SupportCenterScreen(),
    );
  }
}

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF160D38);
  static const Color backgroundGlow = Color(0xFF2A1060);
  static const Color cardSurface = Color(0xFF2E1A72);
  static const Color tileSurface = Color(0xFF3A2280);
  static const Color tileSurfacePressed = Color(0xFF4A2E9A);
  static const Color communityGradientStart = Color(0xFF4A2A9A);
  static const Color communityGradientEnd = Color(0xFF2E1A72);
  static const Color accent = Color(0xFFFFD600);
  static const Color teal = Color(0xFF00D9C0);
  static const Color tealDim = Color(0x3000D9C0);
  static const Color inputBackground = Color(0xFF3D258A);
  static const Color inputBorderFocused = Color(0xFF00D9C0);
  static const Color shimmerBase = Color(0xFF2E1A72);
  static const Color shimmerHighlight = Color(0xFF4A30A0);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB8A8E0);
  static const Color sectionLabel = Color(0xFFD0C0F0);
  static const Color navBackground = Color(0xFF1A0F4A);
  static const Color navPill = Color(0xFF3A2280);
}

class FaqItem {
  final IconData icon;
  final String title;
  final String answer;

  const FaqItem({
    required this.icon,
    required this.title,
    required this.answer,
  });
}

const List<FaqItem> _allFaqs = [
  FaqItem(
    icon: Icons.vaccines_outlined,
    title: 'Vaccination records',
    answer:
        'Go to your child\'s profile → tap "Health Records" → select '
        '"Vaccinations". All administered and upcoming vaccines are listed '
        'there with dates and the clinic name.',
  ),
  FaqItem(
    icon: Icons.lock_reset_outlined,
    title: 'Reset password',
    answer:
        'On the login screen tap "Forgot password?". Enter your registered '
        'email address and we\'ll send you a reset link within 2 minutes. '
        'Check your spam folder if you don\'t see it.',
  ),
  FaqItem(
    icon: Icons.visibility_off_outlined,
    title: 'Privacy settings',
    answer:
        'Open Settings → Privacy. You can control who can see your child\'s '
        'profile, opt out of anonymised data sharing, and download or delete '
        'all your data at any time (PDPA Art. 14).',
  ),
  FaqItem(
    icon: Icons.monitor_weight_outlined,
    title: 'Growth chart not updating',
    answer:
        'Growth charts refresh after you log a new weight or height entry. '
        'Make sure you are connected to the internet at least once so your '
        'local entries sync to the cloud.',
  ),
  FaqItem(
    icon: Icons.notifications_outlined,
    title: 'Turning off reminders',
    answer:
        'Go to Settings → Notifications and toggle off the reminder types you '
        'no longer need. Changes take effect immediately.',
  ),
];

class SupportCenterScreen extends StatefulWidget {
  const SupportCenterScreen({super.key});

  @override
  State<SupportCenterScreen> createState() => _SupportCenterScreenState();
}

class _SupportCenterScreenState extends State<SupportCenterScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late final AnimationController _entranceCtrl;

  List<FaqItem> _filteredFaqs = _allFaqs;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredFaqs = query.isEmpty
          ? _allFaqs
          : _allFaqs
                .where((f) => f.title.toLowerCase().contains(query))
                .toList();
    });
  }

  Animation<double> _stagger(int index) {
    final start = (index * 0.12).clamp(0.0, 0.7);
    final end = (start + 0.45).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _entranceCtrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: _GrowiseAppBar(),
      body: Stack(
        children: [
          const _BackgroundGlow(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              children: [
                _FadeSlide(
                  animation: _stagger(0),
                  child: const _SectionHeading(),
                ),
                const SizedBox(height: 14),

                _FadeSlide(
                  animation: _stagger(1),
                  child: _SearchBar(
                    controller: _searchController,
                    focusNode: _searchFocus,
                  ),
                ),
                const SizedBox(height: 28),

                _FadeSlide(
                  animation: _stagger(2),
                  child: const _LabelRow(label: 'CONTACT US'),
                ),
                const SizedBox(height: 12),
                _FadeSlide(
                  animation: _stagger(3),
                  child: const _ContactUsRow(),
                ),
                const SizedBox(height: 28),

                _FadeSlide(
                  animation: _stagger(4),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'FAQ section',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                _FadeSlide(
                  animation: _stagger(5),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Community & Footer',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FadeSlide extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _FadeSlide({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(child: CustomPaint(painter: _GlowPainter()));
  }
}

class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.6, -0.7),
        radius: 0.9,
        colors: const [Color(0x552A1060), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _GrowiseAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      title: const Text(
        'SUPPORT CENTER',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.0,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading();

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.25,
        ),
        children: [
          TextSpan(
            text: 'How can we ',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          TextSpan(
            text: 'help?',
            style: TextStyle(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _SearchBar({required this.controller, required this.focusNode});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused ? AppColors.inputBorderFocused : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.teal.withOpacity(0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          prefixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.search_rounded,
              key: ValueKey(_focused),
              color: _focused ? AppColors.teal : AppColors.textSecondary,
              size: 22,
            ),
          ),
          hintText: 'Search for help…',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: widget.controller.clear,
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LabelRow extends StatelessWidget {
  final String label;
  final String? trailing;
  const _LabelRow({required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.sectionLabel,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        if (trailing != null)
          GestureDetector(
            onTap: () {},
            child: Text(
              trailing!,
              style: const TextStyle(
                color: AppColors.teal,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _ContactUsRow extends StatelessWidget {
  const _ContactUsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ContactTile(
            icon: Icons.phone_rounded,
            label: 'Helpline',
            subtitle: '+94 11 234…',
            iconColor: AppColors.accent,
            isLive: false,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _ContactTile(
            icon: Icons.email_outlined,
            label: 'Email',
            subtitle: 'support@…',
            iconColor: AppColors.accent,
            isLive: false,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _ContactTile(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Live Chat',
            subtitle: 'Online',
            iconColor: AppColors.teal,
            isLive: true,
          ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color iconColor;
  final bool isLive;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    required this.isLive,
  });

  @override
  State<_ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<_ContactTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _scaleCtrl.forward();
      },
      onTapUp: (_) => _scaleCtrl.reverse(),
      onTapCancel: () => _scaleCtrl.reverse(),
      onTap: () {},
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.tileSurface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.iconColor, size: 26),
              const SizedBox(height: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isLive) ...[
                    const _PulseDot(),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: widget.isLive
                          ? AppColors.teal
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: widget.isLive
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _opacityAnim = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Opacity(
              opacity: _opacityAnim.value,
              child: Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}

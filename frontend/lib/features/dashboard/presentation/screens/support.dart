import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/support_controller.dart';

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
  late final SupportController _controller;
  int _selectedNavIndex = 3;

  bool _faqsLoading = true;
  List<FaqItem> _filteredFaqs = _allFaqs;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(SupportController());
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _faqsLoading = false);
    });

    _searchController.addListener(_onSearchChanged);
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
                  child: _ContactUsRow(
                    onHelplineTap: () => _controller.launchHelpline(),
                    onEmailTap: () => _controller.launchEmail(),
                    onLiveChatTap: () => _controller.showLiveChatComingSoon(),
                  ),
                ),
                const SizedBox(height: 28),

                _FadeSlide(
                  animation: _stagger(4),
                  child: const _LabelRow(label: 'FAQS', trailing: 'View All'),
                ),
                const SizedBox(height: 12),
                _FadeSlide(
                  animation: _stagger(5),
                  child: _faqsLoading
                      ? const _FaqShimmer()
                      : _FaqList(faqs: _filteredFaqs),
                ),
                const SizedBox(height: 28),

                _FadeSlide(
                  animation: _stagger(6),
                  child: const _LabelRow(label: 'Community'),
                ),
                const SizedBox(height: 12),
                _FadeSlide(
                  animation: _stagger(7),
                  child: const _CommunityCard(),
                ),
                const SizedBox(height: 28),

                _FadeSlide(animation: _stagger(8), child: const _Footer()),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: _GrowiseBottomNav(
        selectedIndex: _selectedNavIndex,
        onTap: (i) => setState(() => _selectedNavIndex = i),
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
  final VoidCallback? onHelplineTap;
  final VoidCallback? onEmailTap;
  final VoidCallback? onLiveChatTap;

  const _ContactUsRow({
    this.onHelplineTap,
    this.onEmailTap,
    this.onLiveChatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ContactTile(
            icon: Icons.phone_rounded,
            label: 'Helpline',
            subtitle: '+94 11 234…',
            iconColor: AppColors.accent,
            isLive: false,
            onTap: onHelplineTap,
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
            onTap: onEmailTap,
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
            onTap: onLiveChatTap,
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
  final VoidCallback? onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    required this.isLive,
    this.onTap,
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
      onTap: widget.onTap,
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

class _FaqList extends StatelessWidget {
  final List<FaqItem> faqs;
  const _FaqList({required this.faqs});

  @override
  Widget build(BuildContext context) {
    if (faqs.isEmpty) {
      return const _EmptySearchState();
    }
    return Column(
      children: [
        for (int i = 0; i < faqs.length; i++) ...[
          _FaqTile(item: faqs[i]),
          if (i < faqs.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _FaqTile extends StatefulWidget {
  final FaqItem item;
  const _FaqTile({required this.item});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  late final AnimationController _arrowCtrl;
  late final Animation<double> _arrowAnim;

  @override
  void initState() {
    super.initState();
    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _arrowAnim = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _arrowCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
    _expanded ? _arrowCtrl.forward() : _arrowCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _expanded
              ? AppColors.tileSurfacePressed
              : AppColors.tileSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _expanded ? AppColors.tealDim : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.item.icon,
                      color: AppColors.accent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.item.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  RotationTransition(
                    turns: _arrowAnim,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _expanded
                  ? Padding(
                      padding: const EdgeInsets.only(
                        left: 66,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Text(
                        widget.item.answer,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.55,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.tileSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            color: AppColors.textSecondary.withOpacity(0.5),
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'No results found',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try a different keyword',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _FaqShimmer extends StatefulWidget {
  const _FaqShimmer();

  @override
  State<_FaqShimmer> createState() => _FaqShimmerState();
}

class _FaqShimmerState extends State<_FaqShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _shimmerAnim = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (context, _) {
        return Column(
          children: List.generate(
            3,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: i < 2 ? 10 : 0),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [
                      AppColors.shimmerBase,
                      AppColors.shimmerHighlight,
                      AppColors.shimmerBase,
                    ],
                    stops: [
                      (_shimmerAnim.value - 0.3).clamp(0.0, 1.0),
                      _shimmerAnim.value.clamp(0.0, 1.0),
                      (_shimmerAnim.value + 0.3).clamp(0.0, 1.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CommunityCard extends StatefulWidget {
  const _CommunityCard();

  @override
  State<_CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<_CommunityCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.97,
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
      onTapDown: (_) => _scaleCtrl.forward(),
      onTapUp: (_) => _scaleCtrl.reverse(),
      onTapCancel: () => _scaleCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.communityGradientStart,
                AppColors.communityGradientEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardSurface.withOpacity(0.6),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.groups_rounded,
                                color: AppColors.accent,
                                size: 12,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'DISCUSSION BOARD',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Parent Community',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Connect, share experiences,\nand get advice.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Get.find<SupportController>().launchCommunity(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Visit',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 1, color: AppColors.tileSurface),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerLink('Privacy'),
            _dot(),
            _footerLink('Terms'),
            _dot(),
            _footerLink('Safety'),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '© 2023 Child Care & Development SL',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  Widget _footerLink(String text) => GestureDetector(
    onTap: () {
      /* TODO */
    },
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.textSecondary,
      ),
    ),
  );

  Widget _dot() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 10),
    child: Text(
      '·',
      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
    ),
  );
}

const List<_NavMeta> _navItems = [
  _NavMeta(Icons.home_rounded, Icons.home_outlined, 'Home'),
  _NavMeta(
    Icons.monitor_heart_rounded,
    Icons.monitor_heart_outlined,
    'Tracker',
  ),
  _NavMeta(Icons.school_rounded, Icons.school_outlined, 'Education'),
  _NavMeta(
    Icons.support_agent_rounded,
    Icons.support_agent_outlined,
    'Support',
  ),
];

class _NavMeta {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  const _NavMeta(this.activeIcon, this.inactiveIcon, this.label);
}

class _GrowiseBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _GrowiseBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBackground,
        border: Border(top: BorderSide(color: Color(0xFF2E1A72), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(
              _navItems.length,
              (i) => Expanded(
                child: _NavItem(
                  meta: _navItems[i],
                  isSelected: i == selectedIndex,
                  onTap: () => onTap(i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _NavMeta meta;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.meta,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.teal : AppColors.textSecondary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            width: isSelected ? 48 : 0,
            height: isSelected ? 32 : 0,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.tealDim : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: isSelected
                ? Icon(meta.activeIcon, color: AppColors.teal, size: 22)
                : null,
          ),
          if (!isSelected) ...[Icon(meta.inactiveIcon, color: color, size: 22)],
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
            child: Text(meta.label),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class GroWiseColors {
  GroWiseColors._();
  
  static const Color backgroundDark = Color(0xFF1A0F2E);
  static const Color backgroundPurple = Color(0xFF2D1B4E);
  static const Color accentGold = Color(0xFFFFB84D);
  static const Color primaryPurple = Color(0xFF9B6FD9);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB8B8D8);
  static const Color cardPurple1 = Color(0xFF7D5BA6);
  static const Color cardPurple2 = Color(0xFF6B4A93);
  static const Color cardPurple3 = Color(0xFF5A3980);
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GroWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        // Using default font - no package needed!
        fontFamily: 'Roboto', // Default Flutter font
        colorScheme: ColorScheme.dark(
          primary: GroWiseColors.primaryPurple,
          secondary: GroWiseColors.accentGold,
          background: GroWiseColors.backgroundDark,
          surface: GroWiseColors.backgroundPurple,
        ),
      ),
      home: const OnboardingDetailsPage(),
    );
  }


class OnboardingDetailsPage extends StatefulWidget {
  const OnboardingDetailsPage({super.key});

  @override
  State<OnboardingDetailsPage> createState() => _OnboardingDetailsPageState();
}

class _OnboardingDetailsPageState extends State<OnboardingDetailsPage>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GroWiseColors.backgroundPurple,
              GroWiseColors.backgroundDark,
            ],
            stops: const [0.0, 0.7],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSkipButton(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildHeroSection(),
                          const SizedBox(height: 40),
                          _buildTitleSection(),
                          const SizedBox(height: 40),
                          _buildFeatureCard(
                            title: 'Growth Tracking',
                            description:
                                'Monitor height, weight, and BMI milestones against national standards.',
                            icon: Icons.trending_up_rounded,
                            color: GroWiseColors.cardPurple1,
                            delay: 0,
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            title: 'Health Records',
                            description:
                                'Keep a secure digital log of vaccinations and medical history.',
                            icon: Icons.medical_services_rounded,
                            color: GroWiseColors.cardPurple2,
                            delay: 150,
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            title: 'Expert Resources',
                            description:
                                'Access approved guides on early childhood development.',
                            icon: Icons.school_rounded,
                            color: GroWiseColors.cardPurple3,
                            delay: 300,
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 24.0),
        child: TextButton(
          onPressed: _handleSkip,
          style: TextButton.styleFrom(
            foregroundColor: GroWiseColors.textGray,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Skip',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GroWiseColors.primaryPurple.withOpacity(0.3),
            GroWiseColors.backgroundPurple.withOpacity(0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.family_restroom_rounded,
              size: 100,
              color: GroWiseColors.primaryPurple.withOpacity(0.5),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: GroWiseColors.primaryPurple,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPulsingDot(),
                  const SizedBox(width: 8),
                  const Text(
                    'GROWISE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: GroWiseColors.textWhite,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.3),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: GroWiseColors.accentGold,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        const Text(
          'Empowering Your',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: GroWiseColors.textWhite,
            height: 1.2,
          ),
        ),
        const Text(
          'Parenting Journey',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: GroWiseColors.accentGold,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: GroWiseColors.backgroundDark.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: GroWiseColors.accentGold,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: GroWiseColors.textWhite,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: GroWiseColors.textWhite.withOpacity(0.90),
                      height: 1.5,
                      letterSpacing: 0.2,
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

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: _handleContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: GroWiseColors.accentGold,
            foregroundColor: GroWiseColors.backgroundDark,
            elevation: 6,
            shadowColor: GroWiseColors.accentGold.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSkip() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Skipping to main app...',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: GroWiseColors.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    
    _trackEvent('onboarding_skipped');
  }

  void _handleContinue() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Proceeding to child profile setup...',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: GroWiseColors.backgroundDark,
          ),
        ),
        backgroundColor: GroWiseColors.accentGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
    
    _trackEvent('onboarding_details_completed');
  }

  void _trackEvent(String eventName) {
    print('📊 Analytics Event: $eventName');
  }
}
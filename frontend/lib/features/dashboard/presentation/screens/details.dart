import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const GroWiseApp());
}

class GroWiseColors {
  GroWiseColors._();

  static const Color backgroundDark = Color(0xFF1A0B2E);
  static const Color backgroundPurple = Color(0xFF210F37);
  static const Color accentGold = Color(0xFFD9A574);
  static const Color buttonGold = Color(0xFFFFC44D);
  static const Color primaryPurple = Color(0xFF8B5FBF);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFFB8A8CC);
  static const Color textDark = Color(0xFF2E1A3D);
  static const Color cardPurple = Color(0xFF3A2553);
  static const Color heroGradientTop = Color(0xFFDCC9B8);
  static const Color heroGradientBottom = Color(0xFF4A2F5C);
  static const Color badgePurple = Color(0xFF4F1C51);
  static const Color badgeDot = Color(0xFFE67E9E);
}

class GroWiseApp extends StatelessWidget {
  const GroWiseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GroWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
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
                            delay: 0,
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            title: 'Health Records',
                            description:
                                'Keep a secure digital log of vaccinations and medical history.',
                            icon: Icons.medical_services_rounded,
                            delay: 150,
                          ),
                          const SizedBox(height: 16),
                          _buildFeatureCard(
                            title: 'Expert Resources',
                            description:
                                'Access approved guides on early childhood development.',
                            icon: Icons.school_rounded,
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
          onPressed: () => Get.offAllNamed('/signup-form'),
          style: TextButton.styleFrom(
            foregroundColor: GroWiseColors.textGray,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GroWiseColors.heroGradientTop,
            GroWiseColors.heroGradientBottom,
          ],
          stops: const [0.0, 0.8],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/images/details.png',
              height: 180,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: GroWiseColors.badgePurple,
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
              color: GroWiseColors.badgeDot,
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
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + delay),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: GroWiseColors.cardPurple,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.03),
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
                color: GroWiseColors.backgroundDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(icon, color: GroWiseColors.accentGold, size: 28),
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
                      color: GroWiseColors.textGray,
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
          onPressed: () => Get.toNamed('/signup-form'),
          style: ElevatedButton.styleFrom(
            backgroundColor: GroWiseColors.buttonGold,
            foregroundColor: GroWiseColors.textDark,
            elevation: 6,
            shadowColor: GroWiseColors.buttonGold.withOpacity(0.4),
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
              Icon(Icons.arrow_forward_rounded, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

part of '../figma_flow.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _GreenGradient(
        child: Stack(
          children: [
            const _FloatingDots(),
            Center(
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeOutBack,
                ),
                child: FadeTransition(
                  opacity: _controller,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      _LogoText(color: Colors.white, size: 56, dot: true),
                      SizedBox(height: 16),
                      Text(
                        'Profissionais do seu bairro',
                        style: TextStyle(
                          color: Color(0xCCF7F4EF),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 78,
              left: 0,
              right: 0,
              child: _LoadingDots(),
            ),
          ],
        ),
      ),
    );
  }
}

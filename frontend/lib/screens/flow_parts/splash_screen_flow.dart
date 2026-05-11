part of '../figma_flow.dart';

<<<<<<< HEAD
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
=======
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
>>>>>>> origin/develop
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    Timer(const Duration(milliseconds: 2500), _checkSession);
  }

  Future<void> _checkSession() async {
    if (!mounted) return;
    final token = await AuthApiService.instance.savedToken();
    if (token == null) {
      _navigate(const OnboardingScreen());
      return;
    }
    try {
      final data = await AuthApiService.instance.me();
      final user = AppUser.fromApi(data);
<<<<<<< HEAD
      ref.read(sessionProvider.notifier).setUser(user);
=======
      AppSession.currentUser = user;
>>>>>>> origin/develop
      _navigate(MainShell(user: user));
    } catch (_) {
      await AuthApiService.instance.logout();
      _navigate(const OnboardingScreen());
    }
  }

  void _navigate(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
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
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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

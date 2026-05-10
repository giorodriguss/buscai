import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _dotController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _dotPulse;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // Animação do logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Animação do texto
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Animação do ponto (pulse)
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _dotPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _dotController, curve: Curves.easeInOut),
    );

    // Sequência de animações
    _logoController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _textController.forward();
      });
    });

    // Navegar para onboarding após 2.8s
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const OnboardingScreen(),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(opacity: anim, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.verde,
      body: Stack(
        children: [
          // Círculo decorativo de fundo
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.04),
                  width: 1,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.laranja.withOpacity(0.06),
              ),
            ),
          ),

          // Conteúdo central
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone do app
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (_, __) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: _AppIcon(dotPulse: _dotPulse),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Wordmark "Buscaí"
                AnimatedBuilder(
                  animation: _textController,
                  builder: (_, __) {
                    return Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Opacity(
                        opacity: _textOpacity.value,
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'CormorantGaramond',
                              fontSize: 64,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -2,
                              height: 1,
                            ),
                            children: [
                              TextSpan(
                                text: 'Busca',
                                style: TextStyle(color: Colors.white),
                              ),
                              TextSpan(
                                text: 'í',
                                style: TextStyle(color: AppColors.laranja),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Tagline
                AnimatedBuilder(
                  animation: _textController,
                  builder: (_, __) {
                    return Transform.translate(
                      offset: Offset(0, _textSlide.value * 1.5),
                      child: Opacity(
                        opacity: _textOpacity.value * 0.7,
                        child: const Text(
                          'O vizinho que você precisava encontrar',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            color: Colors.white60,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppIcon extends StatelessWidget {
  final Animation<double> dotPulse;

  const _AppIcon({required this.dotPulse});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: dotPulse,
      builder: (_, __) {
        return Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.07),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Letras "Bí"
              const Center(
                child: Text(
                  'Bí',
                  style: TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
              // Ponto laranja animado
              Positioned(
                bottom: 14,
                right: 14,
                child: Transform.scale(
                  scale: dotPulse.value,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.laranja,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

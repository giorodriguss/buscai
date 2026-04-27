import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _slideController;
  late Animation<double> _slideOpacity;
  late Animation<double> _slideOffset;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      eyebrow: '01 · ENCONTRE',
      title: 'Serviços perto\nde você',
      titleHighlight: 'perto\nde você',
      description:
          'Encontre prestadores de serviço no seu bairro. Pedreiros, eletricistas, diaristas e muito mais.',
      icon: '🔍',
      iconBg: Color(0xFF2A5C40),
    ),
    _OnboardingData(
      eyebrow: '02 · CONECTE',
      title: 'Fale direto pelo\nWhatsApp',
      titleHighlight: 'WhatsApp',
      description:
          'Sem intermediários. Um toque e você está conversando diretamente com o prestador.',
      icon: '💬',
      iconBg: Color(0xFF1E4A32),
    ),
    _OnboardingData(
      eyebrow: '03 · AVALIE',
      title: 'Comunidade que\nse ajuda',
      titleHighlight: 'se ajuda',
      description:
          'Avalie os serviços e consulte as opiniões de moradores do seu bairro antes de contratar.',
      icon: '⭐',
      iconBg: Color(0xFF1A3A2A),
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
    _slideOffset = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.verde,
      body: Stack(
        children: [
          // Círculos decorativos de fundo
          Positioned(
            top: -120,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
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
            bottom: size.height * 0.25,
            left: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.laranja.withOpacity(0.05),
              ),
            ),
          ),

          // PageView das telas
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              _slideController.reset();
              _slideController.forward();
            },
            itemBuilder: (context, index) {
              return _OnboardingPage(
                data: _pages[index],
                slideOpacity: _slideOpacity,
                slideOffset: _slideOffset,
              );
            },
          ),

          // Botões e indicadores na parte de baixo
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _BottomControls(
              currentPage: _currentPage,
              totalPages: _pages.length,
              onNext: _nextPage,
              onSkip: _goToLogin,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dados de cada slide ────────────────────────────────────────────────────

class _OnboardingData {
  final String eyebrow;
  final String title;
  final String titleHighlight;
  final String description;
  final String icon;
  final Color iconBg;

  const _OnboardingData({
    required this.eyebrow,
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.icon,
    required this.iconBg,
  });
}

// ─── Página individual ───────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final Animation<double> slideOpacity;
  final Animation<double> slideOffset;

  const _OnboardingPage({
    required this.data,
    required this.slideOpacity,
    required this.slideOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 60),

          // Ícone grande
          AnimatedBuilder(
            animation: slideOpacity,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, slideOffset.value),
              child: Opacity(
                opacity: slideOpacity.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: data.iconBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      data.icon,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Eyebrow
          AnimatedBuilder(
            animation: slideOpacity,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, slideOffset.value * 1.2),
              child: Opacity(
                opacity: slideOpacity.value,
                child: Text(
                  data.eyebrow,
                  style: const TextStyle(
                    fontFamily: 'DMMono',
                    fontSize: 10,
                    letterSpacing: 3,
                    color: AppColors.laranja,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Título
          AnimatedBuilder(
            animation: slideOpacity,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, slideOffset.value * 1.4),
              child: Opacity(
                opacity: slideOpacity.value,
                child: _HighlightedTitle(
                  text: data.title,
                  highlight: data.titleHighlight,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Descrição
          AnimatedBuilder(
            animation: slideOpacity,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, slideOffset.value * 1.6),
              child: Opacity(
                opacity: slideOpacity.value * 0.6,
                child: Text(
                  data.description,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    height: 1.7,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 200), // espaço para os controles de baixo
        ],
      ),
    );
  }
}

// ─── Título com destaque em laranja ────────────────────────────────────────

class _HighlightedTitle extends StatelessWidget {
  final String text;
  final String highlight;

  const _HighlightedTitle({required this.text, required this.highlight});

  @override
  Widget build(BuildContext context) {
    // Divide o texto na parte destacada e constrói RichText
    final hasHighlight = text.contains(highlight);

    if (!hasHighlight) {
      return Text(
        text,
        style: const TextStyle(
          fontFamily: 'CormorantGaramond',
          fontSize: 52,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          height: 1.0,
          color: Colors.white,
        ),
      );
    }

    final parts = text.split(highlight);

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'CormorantGaramond',
          fontSize: 52,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.5,
          height: 1.05,
        ),
        children: [
          if (parts[0].isNotEmpty)
            TextSpan(
              text: parts[0],
              style: const TextStyle(color: Colors.white),
            ),
          TextSpan(
            text: highlight,
            style: const TextStyle(color: AppColors.laranja),
          ),
          if (parts.length > 1 && parts[1].isNotEmpty)
            TextSpan(
              text: parts[1],
              style: const TextStyle(color: Colors.white),
            ),
        ],
      ),
    );
  }
}

// ─── Controles inferiores ────────────────────────────────────────────────────

class _BottomControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _BottomControls({
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
  });

  bool get isLastPage => currentPage == totalPages - 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        32,
        24,
        32,
        MediaQuery.of(context).padding.bottom + 40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.verde.withOpacity(0),
            AppColors.verde,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicadores de página
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(totalPages, (i) {
              final isActive = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.laranja
                      : Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),

          const SizedBox(height: 32),

          // Botões
          Row(
            children: [
              // Pular
              if (!isLastPage)
                Expanded(
                  child: GestureDetector(
                    onTap: onSkip,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Pular',
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              if (!isLastPage) const SizedBox(width: 12),

              // Avançar / Começar
              Expanded(
                flex: isLastPage ? 1 : 2,
                child: GestureDetector(
                  onTap: onNext,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.laranja,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        isLastPage ? 'Começar' : 'Próximo',
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

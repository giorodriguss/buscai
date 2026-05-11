part of '../figma_flow.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _slide = 0;

  final slides = const [
    (
      image: 'https://images.unsplash.com/photo-1678345201261-1ae7663482bf?w=800&h=900&fit=crop',
      title: 'Profissionais do seu bairro',
      subtitle: 'Conecte-se com prestadores confiáveis e avaliados pelos seus vizinhos',
      orange: false,
    ),
    (
      image: 'https://images.unsplash.com/photo-1649769069590-268b0b994462?w=800&h=900&fit=crop',
      title: 'Serviços de qualidade',
      subtitle: 'De encanadores a manicures, todos os profissionais em um só lugar',
      orange: true,
    ),
    (
      image: 'https://images.unsplash.com/photo-1685586784798-abbf744c69c1?w=800&h=900&fit=crop',
      title: 'Contato direto e rápido',
      subtitle: 'Chat pelo WhatsApp e resolva tudo em minutos, não em dias',
      orange: false,
    ),
  ];

  void _next() {
    if (_slide < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = slides[_slide];
    final colors = current.orange
        ? const [BColors.orange, Color(0xFFC74A1F)]
        : const [BColors.green, BColors.greenDark];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, right: 20),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text(
                      'Pular',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (value) => setState(() => _slide = value),
                  itemCount: slides.length,
                  itemBuilder: (_, index) {
                    final slide = slides[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(30, 8, 30, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 300,
                            height: 400,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x66000000),
                                  blurRadius: 28,
                                  offset: Offset(0, 16),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(slide.image, fit: BoxFit.cover),
                                const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Color(0x99000000),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 38),
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              color: Colors.white,
                              fontSize: 32,
                              height: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            slide.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 42),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(slides.length, (index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          width: index == _slide ? 32 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: index == _slide
                                ? Colors.white
                                : Colors.white.withValues(alpha: .4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _next,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text(
                          _slide == slides.length - 1
                              ? 'Começar agora'
                              : 'Continuar',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: BColors.green,
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

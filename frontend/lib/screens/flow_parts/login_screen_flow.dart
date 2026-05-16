part of '../figma_flow.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _forgotPassword = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? emailError;
  String? passwordError;
  bool _loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() => _doLogin();

  Future<void> _doLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    setState(() {
      emailError = email.isEmpty ? 'Informe o e-mail' : null;
      passwordError = password.isEmpty ? 'Informe a senha' : null;
    });
    if (emailError != null || passwordError != null) return;

    setState(() => _loading = true);
    try {
      final user = await AuthRepository.login(email: email, password: password);
      if (user.isProvider) {
        if (!mounted) return;
        setState(() {
          emailError = 'Este e-mail pertence a uma conta já cadastrada';
          passwordError = null;
        });
        return;
      }
      ref.read(sessionProvider.notifier).setUser(user);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainShell(user: user)),
      );
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message']?.toString() ??
          'Credenciais inválidas';
      if (mounted) {
        setState(() {
          emailError = msg;
          passwordError = 'Verifique sua senha';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_forgotPassword) {
      return ForgotPasswordPage(
        onBack: () => setState(() => _forgotPassword = false),
      );
    }

    return AuthPage(
      centered: true,
      logoSize: 96,
      title: 'Bem-vindo',
      subtitle: 'Entre para encontrar profissionais perto de você',
      fields: [
        FieldSpec(
          Icons.mail_outline_rounded,
          'Seu e-mail',
          TextInputType.emailAddress,
          false,
          controller: emailController,
          errorText: emailError,
          onChanged: (_) => setState(() => emailError = null),
        ),
        FieldSpec(
          Icons.lock_outline_rounded,
          'Sua senha',
          TextInputType.visiblePassword,
          true,
          controller: passwordController,
          errorText: passwordError,
          onChanged: (_) => setState(() => passwordError = null),
        ),
      ],
      forgot: TextButton(
        onPressed: () => setState(() => _forgotPassword = true),
        child: const Text(
          'Esqueceu a senha?',
          style: TextStyle(color: BColors.orange, fontFamily: 'Georgia'),
        ),
      ),
      socialActions: const _SocialLoginButtons(),
      primaryLabel: _loading ? 'Entrando...' : 'Entrar',
      onPrimary: _loading ? () {} : _login,
      secondaryLabel: 'Entrar como Prestador',
      onSecondary: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginProviderScreen()),
      ),
      footer: _AuthFooter(
        text: 'Não tem uma conta?',
        action: 'Criar conta',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SignupScreen()),
        ),
      ),
    );
  }
}

class _SocialLoginButtons extends StatelessWidget {
  const _SocialLoginButtons();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: BColors.border)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'ou entre com',
                style: TextStyle(color: BColors.gray, fontSize: 12),
              ),
            ),
            Expanded(child: Divider(color: BColors.border)),
          ],
        ),
        SizedBox(height: 12),
        _SocialAuthButton(
          provider: _SocialProvider.google,
          label: 'Faça login com o Google',
        ),
        SizedBox(height: 10),
        _SocialAuthButton(
          provider: _SocialProvider.apple,
          label: 'Faça login com a Apple',
        ),
      ],
    );
  }
}

enum _SocialProvider { google, apple }

class _SocialAuthButton extends StatelessWidget {
  final _SocialProvider provider;
  final String label;

  const _SocialAuthButton({required this.provider, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF3B3B3B),
          side: const BorderSide(color: Color(0xFF2F2F2F), width: 1.5),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            provider == _SocialProvider.apple
                ? const Icon(
                    Icons.apple_rounded,
                    size: 30,
                    color: Color(0xFF303030),
                  )
                : const _GoogleGlyph(),
            const SizedBox(width: 14),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        color: Color(0xFF4285F4),
        fontSize: 27,
        fontWeight: FontWeight.w900,
        fontFamily: 'Arial',
      ),
    );
  }
}

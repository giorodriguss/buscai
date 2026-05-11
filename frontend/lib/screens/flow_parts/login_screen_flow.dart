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
  bool loginFailed = false;
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
    if (email.isEmpty || password.isEmpty) {
      setState(() => loginFailed = true);
      return;
    }
    setState(() {
      _loading = true;
      loginFailed = false;
    });
    try {
      final user = await AuthRepository.login(email: email, password: password);
      ref.read(sessionProvider.notifier).setUser(user);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainShell(user: user)),
      );
    } on DioException catch (e) {
      setState(() => loginFailed = true);
      final msg = (e.response?.data as Map?)?['message']?.toString()
          ?? 'Credenciais inválidas';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
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
          errorText: loginFailed ? 'E-mail ou senha incorretos' : null,
        ),
        FieldSpec(
          Icons.lock_outline_rounded,
          'Sua senha',
          TextInputType.visiblePassword,
          true,
          controller: passwordController,
          errorText: loginFailed ? 'Verifique suas credenciais' : null,
        ),
      ],
      forgot: TextButton(
        onPressed: () => setState(() => _forgotPassword = true),
        child: const Text(
          'Esqueceu a senha?',
          style: TextStyle(color: BColors.orange, fontFamily: 'Georgia'),
        ),
      ),
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

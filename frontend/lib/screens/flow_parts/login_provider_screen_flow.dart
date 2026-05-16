part of '../figma_flow.dart';

class LoginProviderScreen extends ConsumerStatefulWidget {
  const LoginProviderScreen({super.key});

  @override
  ConsumerState<LoginProviderScreen> createState() =>
      _LoginProviderScreenState();
}

class _LoginProviderScreenState extends ConsumerState<LoginProviderScreen> {
  bool forgotPassword = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? emailError;
  String? passwordError;
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    setState(() {
      emailError = email.isEmpty ? 'Informe o e-mail' : null;
      passwordError = password.isEmpty ? 'Informe a senha' : null;
    });
    if (emailError != null || passwordError != null) return;

    setState(() => loading = true);
    try {
      final user = await AuthRepository.login(email: email, password: password);
      if (!user.isProvider) {
        setState(() {
          emailError = 'Este e-mail não pertence a uma conta de prestador';
          passwordError = null;
        });
        return;
      }
      ref.read(sessionProvider.notifier).setUser(user);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainShell(user: user)),
      );
    } on DioException {
      if (!mounted) return;
      setState(() {
        emailError = 'E-mail de prestador não encontrado';
        passwordError = 'Senha incorreta ou cadastro inexistente';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (forgotPassword) {
      return ForgotPasswordPage(
        onBack: () => setState(() => forgotPassword = false),
        subtitle:
            'Digite seu e-mail profissional para receber o link de recuperação',
        primaryColor: BColors.green,
        showAppBar: true,
      );
    }
    return AuthPage(
      showBack: true,
      appBarTitle: 'Login de Prestador',
      centered: true,
      title: 'Área do Prestador',
      subtitle: 'Entre para gerenciar seus serviços e clientes',
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
        onPressed: () => setState(() => forgotPassword = true),
        child: const Text('Esqueceu a senha?',
            style: TextStyle(color: BColors.green)),
      ),
      socialActions: const _SocialLoginButtons(),
      primaryLabel: loading ? 'Entrando...' : 'Entrar',
      primaryColor: BColors.green,
      onPrimary: loading ? () {} : _login,
      footer: _AuthFooter(
        text: 'Não tem uma conta?',
        action: 'Criar conta de prestador',
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SignupProviderScreen()),
        ),
      ),
    );
  }
}

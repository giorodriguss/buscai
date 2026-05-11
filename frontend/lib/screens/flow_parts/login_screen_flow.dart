part of '../figma_flow.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      final result = await AuthApiService.instance.login(
        email: email,
        password: password,
      );
      final user = AppUser.fromApi(result['user'] as Map<String, dynamic>);
      AppSession.currentUser = user;
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
      return AuthPage(
        centered: true,
        logoSize: 112,
        title: 'Recuperar senha',
        subtitle: 'Digite seu e-mail para receber o link de recuperação',
        fields: const [
          FieldSpec(Icons.mail_outline_rounded, 'Seu e-mail', TextInputType.emailAddress, false),
        ],
        primaryLabel: 'Enviar link',
        onPrimary: () => setState(() => _forgotPassword = false),
        footer: TextButton(
          onPressed: () => setState(() => _forgotPassword = false),
          child: const Text(
            'Voltar para login',
            style: TextStyle(color: BColors.orange, fontFamily: 'Georgia'),
          ),
        ),
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

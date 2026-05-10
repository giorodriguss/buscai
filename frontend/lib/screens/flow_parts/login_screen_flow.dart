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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showLoginError() {
    // Front temporario: sem backend, login nao autentica. Quando a API existir,
    // trocar por chamada ao endpoint e preencher esses erros conforme a resposta.
    setState(() => loginFailed = true);
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
          errorText: loginFailed ? 'E-mail nao encontrado' : null,
        ),
        FieldSpec(
          Icons.lock_outline_rounded,
          'Sua senha',
          TextInputType.visiblePassword,
          true,
          controller: passwordController,
          errorText: loginFailed ? 'Senha incorreta ou usuario inexistente' : null,
        ),
      ],
      forgot: TextButton(
        onPressed: () => setState(() => _forgotPassword = true),
        child: const Text(
          'Esqueceu a senha?',
          style: TextStyle(color: BColors.orange, fontFamily: 'Georgia'),
        ),
      ),
      primaryLabel: 'Entrar',
      onPrimary: _showLoginError,
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

part of '../figma_flow.dart';

class LoginProviderScreen extends StatefulWidget {
  const LoginProviderScreen({super.key});

  @override
  State<LoginProviderScreen> createState() => _LoginProviderScreenState();
}

class _LoginProviderScreenState extends State<LoginProviderScreen> {
  bool forgotPassword = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loginFailed = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (forgotPassword) {
<<<<<<< HEAD
      return ForgotPasswordPage(
        onBack: () => setState(() => forgotPassword = false),
        subtitle: 'Digite seu e-mail profissional para receber o link de recuperação',
        primaryColor: BColors.green,
        showAppBar: true,
=======
      return AuthPage(
        showBack: true,
        appBarTitle: 'Recuperar senha',
        centered: true,
        logoSize: 112,
        title: 'Recuperar senha',
        subtitle: 'Digite seu e-mail profissional para receber o link de recuperação',
        fields: const [
          FieldSpec(Icons.mail_outline_rounded, 'Seu e-mail', TextInputType.emailAddress, false),
        ],
        primaryLabel: 'Enviar link',
        primaryColor: BColors.green,
        onPrimary: () => setState(() => forgotPassword = false),
        footer: TextButton(
          onPressed: () => setState(() => forgotPassword = false),
          child: const Text('Voltar para login', style: TextStyle(color: BColors.orange)),
        ),
>>>>>>> origin/develop
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
          errorText: loginFailed ? 'E-mail de prestador nao encontrado' : null,
        ),
        FieldSpec(
          Icons.lock_outline_rounded,
          'Sua senha',
          TextInputType.visiblePassword,
          true,
          controller: passwordController,
          errorText: loginFailed ? 'Senha incorreta ou cadastro inexistente' : null,
        ),
      ],
      forgot: TextButton(
        onPressed: () => setState(() => forgotPassword = true),
        child: const Text('Esqueceu a senha?', style: TextStyle(color: BColors.green)),
      ),
      primaryLabel: 'Entrar',
      primaryColor: BColors.green,
      onPrimary: () => setState(() => loginFailed = true),
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
<<<<<<< HEAD
=======

// Cadastro do usuario comum. Valida tudo localmente e grava AppSession.currentUser
// para refletir imediatamente nome, telefone e dados nas telas do prototipo.
>>>>>>> origin/develop

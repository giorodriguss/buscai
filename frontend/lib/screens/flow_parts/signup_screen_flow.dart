part of '../figma_flow.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final validation = <String>{};
  Timer? validationDebounce;

  String? get emailError {
    final value = emailController.text.trim();
    if (value.isEmpty || _isValidEmail(value)) return null;
    return 'Use um e-mail válido no formato nome@email.com';
  }

  String? get phoneError {
    final value = phoneController.text.trim();
    if (value.isEmpty || _isValidPhone(value)) return null;
    return 'Use o formato 00 90000-0000';
  }

  String? get passwordError {
    final value = passwordController.text;
    if (value.isEmpty || (value.length >= 6 && value.length <= 12)) return null;
    return 'A senha deve ter de 6 a 12 caracteres';
  }

  String? get confirmPasswordError {
    final value = confirmPasswordController.text;
    if (value.isEmpty || value == passwordController.text) return null;
    return 'As senhas não conferem';
  }

  @override
  void initState() {
    super.initState();
    // Validação aparece depois que a pessoa sai do campo, não no primeiro caractere.
  }

  void _showValidation(String field) => setState(() => validation.add(field));

  void _queueValidation(String field) {
    // Mesma regra do cadastro de prestador: so mostra erro depois de uma
    // pequena pausa na digitacao; depois o backend pode validar junto.
    validationDebounce?.cancel();
    validationDebounce = Timer(const Duration(milliseconds: 650), () {
      if (mounted) _showValidation(field);
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    validationDebounce?.cancel();
    super.dispose();
  }

  bool _loading = false;

  void _createAccount() => _doCreateAccount();

  Future<void> _doCreateAccount() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      setState(() => validation.addAll(['email', 'phone', 'password', 'confirm']));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome, e-mail, telefone e senha.')),
      );
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => validation.add('email'));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use um e-mail válido no formato nome@email.com.')),
      );
      return;
    }
    if (!_isValidPhone(phone)) {
      setState(() => validation.add('phone'));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use telefone no formato 00 90000-0000.')),
      );
      return;
    }
    if (password.length < 6 || password.length > 12) {
      setState(() => validation.add('password'));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A senha deve ter de 6 a 12 caracteres.')),
      );
      return;
    }
    if (confirmPasswordController.text != password) {
      setState(() => validation.add('confirm'));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não conferem.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthApiService.instance.register(
        fullName: name,
        email: email,
        password: password,
        role: 'cliente',
        phone: phone,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada! Verifique seu e-mail para ativar.')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message']?.toString()
          ?? 'Erro ao criar conta. Tente novamente.';
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
    return AuthPage(
      showBack: true,
      title: 'Vamos começar',
      subtitle: 'Crie sua conta para encontrar profissionais',
      fields: [
        FieldSpec(Icons.person_outline_rounded, 'Nome completo', TextInputType.name, false, controller: nameController),
        FieldSpec(Icons.mail_outline_rounded, 'E-mail', TextInputType.emailAddress, false, controller: emailController, errorText: validation.contains('email') ? emailError : null, onChanged: (_) => _queueValidation('email'), onEditingComplete: () => _showValidation('email')),
        FieldSpec(Icons.phone_outlined, '00 90000-0000', TextInputType.phone, false, controller: phoneController, errorText: validation.contains('phone') ? phoneError : null, inputFormatters: const [PhoneInputFormatter()], onChanged: (_) => _queueValidation('phone'), onEditingComplete: () => _showValidation('phone')),
        FieldSpec(Icons.lock_outline_rounded, 'Senha', TextInputType.visiblePassword, true, controller: passwordController, errorText: validation.contains('password') ? passwordError : null, inputFormatters: [LengthLimitingTextInputFormatter(12)], onChanged: (_) => _queueValidation('password'), onEditingComplete: () => _showValidation('password')),
        FieldSpec(Icons.lock_outline_rounded, 'Confirmar senha', TextInputType.visiblePassword, true, controller: confirmPasswordController, errorText: validation.contains('confirm') ? confirmPasswordError : null, inputFormatters: [LengthLimitingTextInputFormatter(12)], onChanged: (_) => _queueValidation('confirm'), onEditingComplete: () => _showValidation('confirm')),
      ],
      primaryLabel: _loading ? 'Criando conta...' : 'Criar conta',
      onPrimary: _loading ? () {} : _createAccount,
      footer: const Text(
        'Ao criar uma conta, você concorda com nossos Termos de Uso e Política de Privacidade',
        textAlign: TextAlign.center,
        style: TextStyle(color: BColors.gray, fontSize: 12, height: 1.4),
      ),
    );
  }
}

// Cadastro do prestador. Ele cria usuario com isProvider=true e limpa o painel
// Colaborador para a pessoa preencher servicos, disponibilidade e portfolio.

part of '../figma_flow.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with DebouncedValidationMixin<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final cpfController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final validation = <String>{};
  String? apiEmailError;
  String? apiCpfError;
  String? apiPhoneError;
  bool _loading = false;

  String? get nameError =>
      nameController.text.trim().isEmpty ? 'Informe o nome completo' : null;
  String? get emailError =>
      apiEmailError ??
      (emailController.text.trim().isEmpty
          ? 'Informe o e-mail'
          : FormValidators.email(emailController.text.trim()));
  String? get cpfError =>
      apiCpfError ??
      (cpfController.text.trim().isEmpty
          ? 'Informe o CPF'
          : FormValidators.cpf(cpfController.text.trim()));
  String? get phoneError =>
      apiPhoneError ??
      (phoneController.text.trim().isEmpty
          ? 'Informe o telefone'
          : FormValidators.phone(phoneController.text.trim()));
  String? get passwordError => passwordController.text.isEmpty
      ? 'Informe a senha'
      : FormValidators.password(passwordController.text);
  String? get confirmPasswordError => confirmPasswordController.text.isEmpty
      ? 'Confirme a senha'
      : FormValidators.confirmPassword(
          confirmPasswordController.text, passwordController.text);

  void _showValidation(String field) => setState(() => validation.add(field));

  @override
  void dispose() {
    cancelValidationDebounce();
    nameController.dispose();
    emailController.dispose();
    cpfController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _createAccount() => _doCreateAccount();

  Future<void> _doCreateAccount() async {
    final invalidFields = <String>{
      if (nameError != null) 'name',
      if (emailError != null) 'email',
      if (cpfError != null) 'cpf',
      if (phoneError != null) 'phone',
      if (passwordError != null) 'password',
      if (confirmPasswordError != null) 'confirm',
    };
    if (invalidFields.isNotEmpty) {
      setState(() => validation.addAll(invalidFields));
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text;
    setState(() => _loading = true);
    try {
      await AuthRepository.register(
        fullName: nameController.text.trim(),
        email: email,
        password: password,
        cpf: cpfController.text.trim(),
        phone: phoneController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => EmailConfirmationSentScreen(
            email: email,
            password: password,
          ),
        ),
      );
    } on DioException catch (e) {
      final errors = _authFieldErrors(e);
      if (mounted && errors.isNotEmpty) {
        setState(() {
          validation.addAll(errors.keys);
          apiEmailError = errors['email'] ?? apiEmailError;
          apiCpfError = errors['cpf'] ?? apiCpfError;
          apiPhoneError = errors['phone'] ?? apiPhoneError;
        });
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
        FieldSpec(Icons.person_outline_rounded, 'Nome completo',
            TextInputType.name, false,
            controller: nameController,
            errorText: validation.contains('name') ? nameError : null,
            onChanged: (_) => queueValidation(validation, 'name'),
            onEditingComplete: () => _showValidation('name')),
        FieldSpec(Icons.mail_outline_rounded, 'E-mail',
            TextInputType.emailAddress, false,
            controller: emailController,
            errorText: validation.contains('email') ? emailError : null,
            onChanged: (_) {
              apiEmailError = null;
              queueValidation(validation, 'email');
            },
            onEditingComplete: () => _showValidation('email')),
        FieldSpec(
            Icons.badge_outlined, '000.000.000-00', TextInputType.number, false,
            controller: cpfController,
            errorText: validation.contains('cpf') ? cpfError : null,
            inputFormatters: const [CpfInputFormatter()],
            onChanged: (_) {
              apiCpfError = null;
              queueValidation(validation, 'cpf');
            },
            onEditingComplete: () => _showValidation('cpf')),
        FieldSpec(
            Icons.phone_outlined, '00 90000-0000', TextInputType.phone, false,
            controller: phoneController,
            errorText: validation.contains('phone') ? phoneError : null,
            inputFormatters: const [PhoneInputFormatter()],
            onChanged: (_) {
              apiPhoneError = null;
              queueValidation(validation, 'phone');
            },
            onEditingComplete: () => _showValidation('phone')),
        FieldSpec(Icons.lock_outline_rounded, 'Senha',
            TextInputType.visiblePassword, true,
            controller: passwordController,
            errorText: validation.contains('password') ? passwordError : null,
            inputFormatters: [LengthLimitingTextInputFormatter(12)],
            onChanged: (_) => queueValidation(validation, 'password'),
            onEditingComplete: () => _showValidation('password')),
        FieldSpec(Icons.lock_outline_rounded, 'Confirmar senha',
            TextInputType.visiblePassword, true,
            controller: confirmPasswordController,
            errorText:
                validation.contains('confirm') ? confirmPasswordError : null,
            inputFormatters: [LengthLimitingTextInputFormatter(12)],
            onChanged: (_) => queueValidation(validation, 'confirm'),
            onEditingComplete: () => _showValidation('confirm')),
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

Map<String, String> _authFieldErrors(DioException error) {
  final body = error.response?.data;
  final message = body is Map ? body['message'] : null;
  final errors = <String, String>{};

  if (message is Map) {
    message.forEach((key, value) {
      final field = key.toString();
      if (_fieldNames.contains(field)) {
        errors[field] = _friendlyFieldError(field, value.toString());
      }
    });
    return errors;
  }

  if (message is List) {
    for (final item in message) {
      final text = item.toString();
      final field = _authErrorField(text);
      if (field != null) errors[field] = _friendlyFieldError(field, text);
    }
    return errors;
  }

  final text = message?.toString() ?? '';
  final field = _authErrorField(text);
  if (field != null) errors[field] = _friendlyFieldError(field, text);
  return errors;
}

const _fieldNames = {'email', 'cpf', 'phone'};

String? _authErrorField(String message) {
  final normalized = message.toLowerCase();
  if (normalized.contains('cpf')) return 'cpf';
  if (normalized.contains('telefone') || normalized.contains('phone')) {
    return 'phone';
  }
  if (normalized.contains('email') || normalized.contains('e-mail')) {
    return 'email';
  }
  return null;
}

String _friendlyFieldError(String field, String message) {
  return switch (field) {
    'cpf' => _friendlyCpfError(message),
    'phone' => _friendlyPhoneError(message),
    'email' => _friendlyEmailError(message),
    _ => message,
  };
}

String _friendlyCpfError(String message) {
  final normalized = message.toLowerCase();
  if (normalized.contains('cadastrado') ||
      normalized.contains('duplicate') ||
      normalized.contains('unique')) {
    return 'CPF já cadastrado';
  }
  if (normalized.contains('inválido') ||
      normalized.contains('invalido') ||
      normalized.contains('length') ||
      normalized.contains('constraint')) {
    return 'CPF inválido. Use 11 dígitos.';
  }
  return message;
}

String _friendlyPhoneError(String message) {
  final normalized = message.toLowerCase();
  if (normalized.contains('cadastrado') ||
      normalized.contains('duplicate') ||
      normalized.contains('unique')) {
    return 'Telefone já cadastrado';
  }
  return message;
}

String _friendlyEmailError(String message) {
  final normalized = message.toLowerCase();
  if (normalized.contains('cadastrado') ||
      normalized.contains('registered') ||
      normalized.contains('already') ||
      normalized.contains('duplicate') ||
      normalized.contains('unique')) {
    return 'E-mail já cadastrado';
  }
  return message;
}

class EmailConfirmationSentScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;
  final String? providerCategory;

  const EmailConfirmationSentScreen({
    super.key,
    required this.email,
    required this.password,
    this.providerCategory,
  });

  @override
  ConsumerState<EmailConfirmationSentScreen> createState() =>
      _EmailConfirmationSentScreenState();
}

class _EmailConfirmationSentScreenState
    extends ConsumerState<EmailConfirmationSentScreen> {
  Timer? _pollTimer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Futuro backend/Supabase: preferir listener de auth state/deep link de
    // confirmacao. Este polling e temporario para o prototipo local.
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _tryLogin());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _tryLogin() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final user = await AuthRepository.login(
        email: widget.email,
        password: widget.password,
      );
      if (user.email.isEmpty) user.email = widget.email;
      if (!mounted) return;
      _pollTimer?.cancel();
      if (widget.providerCategory != null) {
        ref.read(collaboratorProvider.notifier).reset(widget.providerCategory!);
      }
      ref.read(sessionProvider.notifier).setUser(user);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainShell(user: user)),
      );
    } on DioException {
      // A conta ainda nao foi confirmada. Mantemos a tela aguardando e o
      // polling continua tentando entrar automaticamente.
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 96, 32, 32),
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: BColors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Confirme seu e-mail',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Georgia',
                fontSize: 29,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Enviamos um link de confirmação para o seu e-mail.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: BColors.gray, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Por favor, verifique sua caixa de entrada e clique no link para ativar sua conta.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BColors.gray, fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 34),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: cardDecoration(radius: 14),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(radius: 12, backgroundColor: BColors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Não recebeu o e-mail?',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Verifique sua pasta de spam ou lixo eletrônico. O e-mail pode levar alguns minutos para chegar.',
                          style: TextStyle(
                            color: BColors.gray,
                            height: 1.45,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Já confirmei meu e-mail',
              icon: Icons.check_circle_outline_rounded,
              onPressed: _checking ? () {} : _tryLogin,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Voltar ao início'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: BColors.green,
                  side: const BorderSide(color: BColors.green, width: 1.6),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            TextButton(
              onPressed: () {
                // Futuro backend/Supabase: chamar reenvio de confirmação para
                // widget.email. Sem snackbar porque no app final haverá fluxo
                // real de envio.
              },
              child: const Text(
                'Reenviar e-mail de confirmação',
                style: TextStyle(
                  color: BColors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

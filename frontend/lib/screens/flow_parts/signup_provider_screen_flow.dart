part of '../figma_flow.dart';

class SignupProviderScreen extends ConsumerStatefulWidget {
  const SignupProviderScreen({super.key});

  @override
  ConsumerState<SignupProviderScreen> createState() =>
      _SignupProviderScreenState();
}

class _SignupProviderScreenState extends ConsumerState<SignupProviderScreen>
    with DebouncedValidationMixin<SignupProviderScreen> {
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
  late String selectedCategory;

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
  void initState() {
    super.initState();
    selectedCategory = CategorySelectionScreen.categories.first;
  }

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

  void _createProviderAccount() => _doCreateProviderAccount();

  Future<void> _doCreateProviderAccount() async {
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
    try {
      await AuthRepository.registerProvider(
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
            providerCategory: selectedCategory,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColors.paper,
      appBar: const _GreenAppBar(title: 'Cadastro de Prestador'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: BColors.green, width: 2),
              ),
              child: const Row(
                children: [
                  CircleAvatar(radius: 24, backgroundColor: BColors.orange),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seja um prestador',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                        SizedBox(height: 3),
                        Text('Cadastre-se e receba clientes',
                            style: TextStyle(color: BColors.gray)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Text('Categoria profissional',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextInputLike(
              icon: Icons.work_outline_rounded,
              hint: selectedCategory,
              readOnly: true,
              suffixIcon: Icons.keyboard_arrow_down_rounded,
              onTap: () async {
                final category = await Navigator.of(context).push<String>(
                  MaterialPageRoute(
                      builder: (_) => const CategorySelectionScreen()),
                );
                if (category != null) {
                  setState(() => selectedCategory = category);
                }
              },
            ),
            const SizedBox(height: 16),
            TextInputLike(
              icon: Icons.person_outline_rounded,
              hint: 'Nome completo',
              keyboardType: TextInputType.name,
              controller: nameController,
              errorText: validation.contains('name') ? nameError : null,
              onChanged: (_) => queueValidation(validation, 'name'),
              onEditingComplete: () => _showValidation('name'),
            ),
            const SizedBox(height: 16),
            TextInputLike(
              icon: Icons.mail_outline_rounded,
              hint: 'E-mail',
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              errorText: validation.contains('email') ? emailError : null,
              onChanged: (_) {
                apiEmailError = null;
                queueValidation(validation, 'email');
              },
              onEditingComplete: () => _showValidation('email'),
            ),
            const SizedBox(height: 16),
            TextInputLike(
              icon: Icons.badge_outlined,
              hint: '000.000.000-00',
              keyboardType: TextInputType.number,
              controller: cpfController,
              errorText: validation.contains('cpf') ? cpfError : null,
              inputFormatters: const [CpfInputFormatter()],
              onChanged: (_) {
                apiCpfError = null;
                queueValidation(validation, 'cpf');
              },
              onEditingComplete: () => _showValidation('cpf'),
            ),
            const SizedBox(height: 16),
            TextInputLike(
              icon: Icons.phone_outlined,
              hint: '00 90000-0000',
              keyboardType: TextInputType.phone,
              controller: phoneController,
              errorText: validation.contains('phone') ? phoneError : null,
              inputFormatters: const [PhoneInputFormatter()],
              onChanged: (_) {
                apiPhoneError = null;
                queueValidation(validation, 'phone');
              },
              onEditingComplete: () => _showValidation('phone'),
            ),
            const SizedBox(height: 16),
            TextInputLike(
              icon: Icons.lock_outline_rounded,
              hint: 'Senha',
              obscure: true,
              controller: passwordController,
              errorText: validation.contains('password') ? passwordError : null,
              inputFormatters: [LengthLimitingTextInputFormatter(12)],
              onChanged: (_) => queueValidation(validation, 'password'),
              onEditingComplete: () => _showValidation('password'),
            ),
            const SizedBox(height: 16),
            TextInputLike(
              icon: Icons.lock_outline_rounded,
              hint: 'Confirmar senha',
              obscure: true,
              controller: confirmPasswordController,
              errorText:
                  validation.contains('confirm') ? confirmPasswordError : null,
              inputFormatters: [LengthLimitingTextInputFormatter(12)],
              onChanged: (_) => queueValidation(validation, 'confirm'),
              onEditingComplete: () => _showValidation('confirm'),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Criar conta de prestador',
              color: BColors.green,
              onPressed: _createProviderAccount,
            ),
            const SizedBox(height: 18),
            const Text(
              'Ao criar uma conta, você concorda com nossos\nTermos de Uso e Política de Privacidade',
              textAlign: TextAlign.center,
              style: TextStyle(color: BColors.green, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

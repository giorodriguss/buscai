part of '../figma_flow.dart';

class SignupProviderScreen extends ConsumerStatefulWidget {
  const SignupProviderScreen({super.key});

  @override
  ConsumerState<SignupProviderScreen> createState() => _SignupProviderScreenState();
}

class _SignupProviderScreenState extends ConsumerState<SignupProviderScreen>
    with DebouncedValidationMixin<SignupProviderScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final validation = <String>{};
  late String selectedCategory;

  String? get emailError => FormValidators.email(emailController.text.trim());
  String? get phoneError => FormValidators.phone(phoneController.text.trim());
  String? get passwordError => FormValidators.password(passwordController.text);
  String? get confirmPasswordError =>
      FormValidators.confirmPassword(confirmPasswordController.text, passwordController.text);

  void _showValidation(String field) => setState(() => validation.add(field));

  @override
  void initState() {
    super.initState();
    selectedCategory = ref.read(collaboratorProvider).category;
  }

  @override
  void dispose() {
    cancelValidationDebounce();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _createProviderAccount() {
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
    final user = AppUser(name: name, email: email, phone: phone, isProvider: true);
    ref.read(collaboratorProvider.notifier).reset(selectedCategory);
    ref.read(sessionProvider.notifier).setUser(user);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainShell(user: user)),
    );
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
                        Text('Seja um prestador', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        SizedBox(height: 3),
                        Text('Cadastre-se e receba clientes', style: TextStyle(color: BColors.gray)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Text('Categoria profissional', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextInputLike(
              icon: Icons.work_outline_rounded,
              hint: selectedCategory,
              readOnly: true,
              suffixIcon: Icons.keyboard_arrow_down_rounded,
              onTap: () async {
                final category = await Navigator.of(context).push<String>(
                  MaterialPageRoute(builder: (_) => const CategorySelectionScreen()),
                );
                if (category != null) setState(() => selectedCategory = category);
              },
            ),
            const SizedBox(height: 16),
            TextInputLike(
              icon: Icons.person_outline_rounded,
              hint: 'Nome completo',
              keyboardType: TextInputType.name,
              controller: nameController,
            ),
            const SizedBox(height: 16),
            TextInputLike(
              icon: Icons.mail_outline_rounded,
              hint: 'E-mail',
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              errorText: validation.contains('email') ? emailError : null,
              onChanged: (_) => queueValidation(validation, 'email'),
              onEditingComplete: () => _showValidation('email'),
            ),
            const SizedBox(height: 16),
            TextInputLike(
              icon: Icons.phone_outlined,
              hint: '00 90000-0000',
              keyboardType: TextInputType.phone,
              controller: phoneController,
              errorText: validation.contains('phone') ? phoneError : null,
              inputFormatters: const [PhoneInputFormatter()],
              onChanged: (_) => queueValidation(validation, 'phone'),
              onEditingComplete: () => _showValidation('phone'),
            ),
            const SizedBox(height: 16),
            const TextInputLike(icon: Icons.location_on_outlined, hint: 'Seu bairro'),
            const SizedBox(height: 16),
            TextInputLike(icon: Icons.lock_outline_rounded, hint: 'Senha', obscure: true, controller: passwordController, errorText: validation.contains('password') ? passwordError : null, inputFormatters: [LengthLimitingTextInputFormatter(12)], onChanged: (_) => queueValidation(validation, 'password'), onEditingComplete: () => _showValidation('password')),
            const SizedBox(height: 16),
            TextInputLike(icon: Icons.lock_outline_rounded, hint: 'Confirmar senha', obscure: true, controller: confirmPasswordController, errorText: validation.contains('confirm') ? confirmPasswordError : null, inputFormatters: [LengthLimitingTextInputFormatter(12)], onChanged: (_) => queueValidation(validation, 'confirm'), onEditingComplete: () => _showValidation('confirm')),
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

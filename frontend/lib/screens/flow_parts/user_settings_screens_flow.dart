part of '../figma_flow.dart';

class EditUserProfileScreen extends ConsumerStatefulWidget {
  final AppUser user;

  const EditUserProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditUserProfileScreen> createState() =>
      _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends ConsumerState<EditUserProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController cpfController;
  late final TextEditingController phoneController;
  final validation = <String>{};
  String? apiEmailError;
  String? apiCpfError;
  String? apiPhoneError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    cpfController = TextEditingController(text: widget.user.cpf);
    phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    cpfController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromDevice() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1200,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final mime = picked.mimeType ?? 'image/jpeg';
    final user = widget.user;
    // Salvamento local temporario. Futuro backend: subir bytes para Storage e
    // salvar a URL retornada em avatar_url.
    user.photoUrl = 'data:$mime;base64,${base64Encode(bytes)}';
    ref.read(sessionProvider.notifier).setUser(user);
    setState(() {});
  }

  void _selectProfileImage() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: BColors.green),
              title: const Text('Selecionar da galeria'),
              onTap: () async {
                Navigator.of(context).pop();
                await _pickImageFromDevice();
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.folder_open_outlined, color: BColors.green),
              title: const Text('Selecionar dos arquivos'),
              onTap: () async {
                Navigator.of(context).pop();
                await _pickImageFromDevice();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final emailError = FormValidators.email(emailController.text.trim());
    final cpfError = FormValidators.cpf(cpfController.text.trim());
    final phoneError = FormValidators.phone(phoneController.text.trim());
    setState(() {
      validation
        ..clear()
        ..addAll([
          if (emailError != null) 'email',
          if (cpfError != null) 'cpf',
          if (phoneError != null) 'phone',
        ]);
    });
    if (emailError != null || cpfError != null || phoneError != null) return;

    try {
      final updatedUser = await AuthRepository.updateMe(
        fullName: nameController.text.trim(),
        cpf: cpfController.text.trim(),
        phone: phoneController.text.trim(),
      );
      updatedUser.email = emailController.text.trim();
      updatedUser.photoUrl = widget.user.photoUrl;
      ref.read(sessionProvider.notifier).setUser(updatedUser);
      if (mounted) Navigator.of(context).pop();
    } on DioException catch (e) {
      final errors = _authFieldErrors(e);
      if (!mounted) return;
      if (errors.isNotEmpty) {
        setState(() {
          validation.addAll(errors.keys);
          apiCpfError = errors['cpf'] ?? apiCpfError;
          apiPhoneError = errors['phone'] ?? apiPhoneError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = AppUser(
      id: widget.user.id,
      name: nameController.text.trim().isEmpty
          ? widget.user.name
          : nameController.text.trim(),
      email: emailController.text.trim(),
      cpf: cpfController.text.trim(),
      phone: phoneController.text.trim(),
      photoUrl: widget.user.photoUrl,
      neighborhood: widget.user.neighborhood,
      isProvider: widget.user.isProvider,
    );
    return Scaffold(
      backgroundColor: BColors.paper,
      appBar: const _GreenAppBar(title: 'Editar perfil'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
        children: [
          Center(
            child: _EditableUserAvatar(
              user: preview,
              radius: 52,
              onCameraTap: _selectProfileImage,
            ),
          ),
          const SizedBox(height: 20),
          const Text('Nome', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(
              icon: Icons.person_outline_rounded,
              hint: 'Nome',
              controller: nameController),
          const SizedBox(height: 18),
          const Text('E-mail', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(
            icon: Icons.mail_outline_rounded,
            hint: 'E-mail',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            errorText: validation.contains('email')
                ? apiEmailError ??
                    FormValidators.email(emailController.text.trim())
                : null,
            onChanged: (_) => setState(() => apiEmailError = null),
          ),
          const SizedBox(height: 18),
          const Text('CPF', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(
            icon: Icons.badge_outlined,
            hint: '000.000.000-00',
            controller: cpfController,
            keyboardType: TextInputType.number,
            inputFormatters: const [CpfInputFormatter()],
            errorText: validation.contains('cpf')
                ? apiCpfError ?? FormValidators.cpf(cpfController.text.trim())
                : null,
            onChanged: (_) => setState(() => apiCpfError = null),
          ),
          const SizedBox(height: 18),
          const Text('Telefone', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(
            icon: Icons.phone_outlined,
            hint: '00 90000-0000',
            controller: phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: const [PhoneInputFormatter()],
            errorText: validation.contains('phone')
                ? FormValidators.phone(phoneController.text.trim())
                : null,
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Salvar alterações', onPressed: _save),
        ],
      ),
    );
  }
}

class AccountSettingsScreen extends ConsumerStatefulWidget {
  final AppUser user;

  const AccountSettingsScreen({super.key, required this.user});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  late final TextEditingController nameController;
  late final TextEditingController cpfController;
  late final TextEditingController phoneController;
  final validation = <String>{};
  String? apiCpfError;
  String? apiPhoneError;

  @override
  void initState() {
    super.initState();
    final activeUser = ref.read(sessionProvider).currentUser ?? widget.user;
    nameController = TextEditingController(text: activeUser.name);
    cpfController = TextEditingController(text: activeUser.cpf);
    phoneController = TextEditingController(text: activeUser.phone);
  }

  @override
  void dispose() {
    nameController.dispose();
    cpfController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromDevice(AppUser activeUser) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1200,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final mime = picked.mimeType ?? 'image/jpeg';
    activeUser.photoUrl = 'data:$mime;base64,${base64Encode(bytes)}';
    ref.read(sessionProvider.notifier).setUser(activeUser);
    setState(() {});
  }

  void _selectProfileImage(AppUser activeUser) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: BColors.green),
              title: const Text('Selecionar da galeria'),
              onTap: () async {
                Navigator.of(context).pop();
                await _pickImageFromDevice(activeUser);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.folder_open_outlined, color: BColors.green),
              title: const Text('Selecionar dos arquivos'),
              onTap: () async {
                Navigator.of(context).pop();
                await _pickImageFromDevice(activeUser);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(AppUser activeUser) async {
    final cpfError = FormValidators.cpf(cpfController.text.trim());
    final phoneError = FormValidators.phone(phoneController.text.trim());
    setState(() {
      validation
        ..clear()
        ..addAll([
          if (cpfError != null) 'cpf',
          if (phoneError != null) 'phone',
        ]);
    });
    if (cpfError != null || phoneError != null) return;

    try {
      final updatedUser = await AuthRepository.updateMe(
        fullName: nameController.text.trim(),
        cpf: cpfController.text.trim(),
        phone: phoneController.text.trim(),
      );
      updatedUser.email = activeUser.email;
      updatedUser.photoUrl = activeUser.photoUrl;
      ref.read(sessionProvider.notifier).setUser(updatedUser);
    } on DioException catch (e) {
      final errors = _authFieldErrors(e);
      if (!mounted) return;
      if (errors.isNotEmpty) {
        setState(() {
          validation.addAll(errors.keys);
          apiCpfError = errors['cpf'] ?? apiCpfError;
          apiPhoneError = errors['phone'] ?? apiPhoneError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = ref.watch(sessionProvider).currentUser ?? widget.user;
    final session = ref.watch(sessionProvider);
    final preview = AppUser(
      id: activeUser.id,
      name: nameController.text.trim().isEmpty
          ? activeUser.name
          : nameController.text.trim(),
      email: activeUser.email,
      cpf: cpfController.text.trim(),
      phone: phoneController.text.trim(),
      photoUrl: activeUser.photoUrl,
      neighborhood: activeUser.neighborhood,
      isProvider: activeUser.isProvider,
    );

    return SimplePage(
      title: 'Configurações',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: cardDecoration(radius: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: _EditableUserAvatar(
                    user: preview,
                    radius: 52,
                    onCameraTap: () => _selectProfileImage(activeUser),
                  ),
                ),
                const SizedBox(height: 22),
                const Text('Dados do perfil',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                TextInputLike(
                    icon: Icons.person_outline_rounded,
                    hint: 'Nome',
                    controller: nameController),
                const SizedBox(height: 12),
                TextInputLike(
                  icon: Icons.badge_outlined,
                  hint: '000.000.000-00',
                  controller: cpfController,
                  keyboardType: TextInputType.number,
                  inputFormatters: const [CpfInputFormatter()],
                  errorText: validation.contains('cpf')
                      ? apiCpfError ??
                          FormValidators.cpf(cpfController.text.trim())
                      : null,
                  onChanged: (_) => setState(() => apiCpfError = null),
                ),
                const SizedBox(height: 12),
                TextInputLike(
                  icon: Icons.phone_outlined,
                  hint: '00 90000-0000',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: const [PhoneInputFormatter()],
                  errorText: validation.contains('phone')
                      ? apiPhoneError ??
                          FormValidators.phone(phoneController.text.trim())
                      : null,
                  onChanged: (_) => setState(() => apiPhoneError = null),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                    label: 'Salvar alterações',
                    onPressed: () => _save(activeUser)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (activeUser.isProvider) ...[
            _SwitchCard(
              icon: Icons.visibility_outlined,
              title: 'Perfil público do colaborador',
              subtitle:
                  'Quando ativado, seu perfil aparece para moradores na Home e na busca.',
              value: session.profileVisible,
              onChanged: ref.read(sessionProvider.notifier).setProfileVisible,
            ),
            const SizedBox(height: 18),
          ],
          Container(
            decoration: cardDecoration(radius: 14),
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.alternate_email_rounded,
                  label: 'Alterar e-mail',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChangeEmailScreen(user: activeUser),
                    ),
                  ),
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.lock_reset_rounded,
                  label: 'Redefinir senha',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ResetPasswordScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChangeEmailScreen extends ConsumerStatefulWidget {
  final AppUser user;

  const ChangeEmailScreen({super.key, required this.user});

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  final emailController = TextEditingController();
  String? emailError;
  bool sent = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final activeUser = ref.read(sessionProvider).currentUser ?? widget.user;
    final nextEmail = emailController.text.trim();
    final validationError = FormValidators.email(nextEmail);
    setState(() {
      emailError = nextEmail.isEmpty
          ? 'Informe o novo e-mail'
          : validationError ??
              (nextEmail == activeUser.email
                  ? 'Use um e-mail diferente do atual'
                  : null);
    });
    if (emailError != null) return;

    // Futuro backend/Supabase: chamar auth.updateUser({ email: nextEmail }) ou
    // uma rota POST /auth/change-email para disparar o link de verificacao.
    // O e-mail local so deve ser atualizado depois da confirmacao do link.
    setState(() => sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = ref.watch(sessionProvider).currentUser ?? widget.user;
    return SimplePage(
      title: 'Alterar e-mail',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SettingsHeroCard(
            icon: Icons.mark_email_read_outlined,
            title: 'Verifique o novo e-mail',
            text:
                'Para proteger sua conta, enviaremos um link para o novo endereço. O e-mail do perfil só será atualizado depois que você confirmar pelo link.',
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: cardDecoration(radius: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('E-mail atual',
                    style: TextStyle(color: BColors.gray, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  activeUser.email.isEmpty
                      ? 'E-mail não informado'
                      : activeUser.email,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextInputLike(
            icon: Icons.alternate_email_rounded,
            hint: 'Novo e-mail',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            errorText: emailError,
            onChanged: (_) => setState(() => emailError = null),
            onEditingComplete: _submit,
          ),
          if (sent) ...[
            const SizedBox(height: 12),
            const _InfoCard(
              icon: Icons.info_outline_rounded,
              title: 'Link enviado',
              text:
                  'Enviamos um link para o novo endereço. Depois da confirmação, o e-mail do perfil será atualizado.',
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Enviar link de verificação',
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);
    final unreadCount =
        session.notifications.where((item) => item.unread).length;

    return SimplePage(
      title: 'Notificações',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsHeroCard(
            icon: Icons.notifications_active_outlined,
            title:
                '$unreadCount aviso${unreadCount == 1 ? '' : 's'} novo${unreadCount == 1 ? '' : 's'}',
            text:
                'Acompanhe confirmações de serviços, avaliações e avisos importantes do app.',
          ),
          const SizedBox(height: 14),
          _SwitchCard(
            icon: Icons.notifications_active_outlined,
            title: 'Alertas do app',
            subtitle: 'Ativar ou desativar notificações gerais.',
            value: session.notificationsEnabled,
            onChanged: notifier.setNotificationsEnabled,
          ),
          _SwitchCard(
            icon: Icons.calendar_month_outlined,
            title: 'Alertas de serviço',
            subtitle: 'Receber lembretes sobre agendamentos e atendimentos.',
            value: session.serviceAlertsEnabled,
            onChanged: session.notificationsEnabled
                ? notifier.setServiceAlertsEnabled
                : null,
          ),
          const SizedBox(height: 6),
          const SectionTitle('Histórico', size: 18),
          const SizedBox(height: 10),
          if (session.notifications.isEmpty)
            const _InfoCard(
              icon: Icons.notifications_none_rounded,
              title: 'Nada por enquanto',
              text: 'Quando houver novidades do app, elas aparecerão aqui.',
            )
          else
            ...session.notifications.map(
              (notification) => _NotificationHistoryTile(
                notification: notification,
                onTap: () => notifier.markNotificationRead(notification.id),
              ),
            ),
        ],
      ),
    );
  }
}

class PrivacySecurityScreen extends ConsumerWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);
    return SimplePage(
      title: 'Privacidade',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SettingsHeroCard(
            icon: Icons.shield_outlined,
            title: 'Privacidade e segurança',
            text:
                'Controle visibilidade, uso de dados e ações sensíveis da sua conta.',
          ),
          const SizedBox(height: 14),
          _SwitchCard(
            icon: Icons.visibility_outlined,
            title: 'Perfil visível',
            subtitle:
                'Permitir que seu perfil apareça nas áreas públicas do app.',
            value: session.profileVisible,
            onChanged: notifier.setProfileVisible,
          ),
          _SwitchCard(
            icon: Icons.analytics_outlined,
            title: 'Uso de dados',
            subtitle: 'Autorizar uso de dados para melhorar recomendações.',
            value: session.dataSharingEnabled,
            onChanged: notifier.setDataSharingEnabled,
          ),
          Container(
            decoration: cardDecoration(radius: 14),
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.download_outlined,
                  label: 'Exportar meus dados',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final currentController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  String? currentError;
  String? passwordError;
  String? confirmError;
  bool loading = false;
  bool checkingCurrent = false;
  int _currentCheckTicket = 0;

  @override
  void dispose() {
    currentController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<bool> _validateCurrentPassword() async {
    final value = currentController.text;
    if (value.isEmpty) {
      setState(() => currentError = 'Informe sua senha atual');
      return false;
    }

    final ticket = ++_currentCheckTicket;
    setState(() {
      checkingCurrent = true;
      currentError = null;
    });
    try {
      await AuthRepository.verifyPassword(currentPassword: value);
      if (!mounted || ticket != _currentCheckTicket) return false;
      setState(() => currentError = null);
      return true;
    } on DioException catch (e) {
      final message = (e.response?.data as Map?)?['message']?.toString();
      if (!mounted || ticket != _currentCheckTicket) return false;
      setState(() {
        currentError = message?.contains('Senha atual') == true
            ? 'Senha atual não confere'
            : 'Não foi possível verificar a senha agora';
      });
      return false;
    } finally {
      if (mounted && ticket == _currentCheckTicket) {
        setState(() => checkingCurrent = false);
      }
    }
  }

  bool _validateNewPassword() {
    final error = passwordController.text.isEmpty
        ? 'Informe a nova senha'
        : FormValidators.password(passwordController.text);
    setState(() {
      passwordError = error;
      if (confirmController.text.isNotEmpty) {
        confirmError = FormValidators.confirmPassword(
          confirmController.text,
          passwordController.text,
        );
      }
    });
    return error == null;
  }

  bool _validateConfirmPassword() {
    final error = confirmController.text.isEmpty
        ? 'Confirme a nova senha'
        : FormValidators.confirmPassword(
            confirmController.text,
            passwordController.text,
          );
    setState(() => confirmError = error);
    return error == null;
  }

  Future<void> _submit() async {
    final currentOk = await _validateCurrentPassword();
    final passwordOk = _validateNewPassword();
    final confirmOk = _validateConfirmPassword();
    if (!currentOk || !passwordOk || !confirmOk) return;

    setState(() => loading = true);
    try {
      await AuthRepository.changePassword(
        currentPassword: currentController.text,
        newPassword: passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on DioException catch (e) {
      final message = (e.response?.data as Map?)?['message']?.toString();
      if (!mounted) return;
      setState(() {
        currentError = message?.contains('Senha atual') == true
            ? 'Senha atual não confere'
            : currentError;
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimplePage(
      title: 'Redefinir senha',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SettingsHeroCard(
            icon: Icons.lock_reset_rounded,
            title: 'Proteja sua conta',
            text:
                'Confirme sua senha atual e escolha uma nova senha de 6 a 12 caracteres.',
          ),
          const SizedBox(height: 18),
          TextInputLike(
            icon: checkingCurrent
                ? Icons.hourglass_top_rounded
                : Icons.lock_outline_rounded,
            hint: 'Senha atual',
            controller: currentController,
            obscure: true,
            errorText: currentError,
            onEditingComplete: () {
              _validateCurrentPassword();
            },
          ),
          const SizedBox(height: 12),
          TextInputLike(
            icon: Icons.lock_reset_rounded,
            hint: 'Nova senha',
            controller: passwordController,
            obscure: true,
            errorText: passwordError,
            onEditingComplete: () {
              _validateNewPassword();
            },
          ),
          const SizedBox(height: 12),
          TextInputLike(
            icon: Icons.lock_reset_rounded,
            hint: 'Confirmar nova senha',
            controller: confirmController,
            obscure: true,
            errorText: confirmError,
            onEditingComplete: () {
              _validateConfirmPassword();
            },
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: loading ? 'Atualizando...' : 'Atualizar senha',
            onPressed: loading ? () {} : _submit,
          ),
        ],
      ),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SimplePage(
      title: 'Ajuda e suporte',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SettingsHeroCard(
            icon: Icons.help_outline_rounded,
            title: 'Central de ajuda',
            text:
                'Artigos rápidos para moradores e prestadores resolverem as dúvidas mais comuns.',
          ),
          const SizedBox(height: 14),
          const SectionTitle('Artigos', size: 18),
          const SizedBox(height: 10),
          const _HelpArticleTile(
            icon: Icons.search_rounded,
            title: 'Como encontrar um prestador',
            text:
                'Use Buscar ou Home para filtrar por categoria, nome do serviço, bairro e avaliação. Abra o perfil para conferir valores, serviços e comentários.',
          ),
          const _HelpArticleTile(
            icon: Icons.event_available_outlined,
            title: 'Como agendar um serviço',
            text:
                'No perfil do prestador, escolha serviço, dia e horário. Ao tocar em Agendar, o WhatsApp abre e o serviço fica pendente em Meus Serviços.',
          ),
          const _HelpArticleTile(
            icon: Icons.check_circle_outline_rounded,
            title: 'Pendente, realizado e avaliado',
            text:
                'Pendente ainda precisa acontecer. Realizado já foi confirmado pelo morador. Avaliado mostra que a nota entrou no perfil do prestador.',
          ),
          const _HelpArticleTile(
            icon: Icons.verified_user_outlined,
            title: 'Confirmação pelo morador',
            text:
                'Se o prestador marcar como realizado, o morador confirma antes de o atendimento contar nas estatísticas do perfil.',
          ),
          const _HelpArticleTile(
            icon: Icons.star_border_rounded,
            title: 'Como avaliar',
            text:
                'Depois que o serviço estiver realizado, toque em Avaliar, escolha a nota e escreva um comentário. A avaliação aparece no perfil do prestador.',
          ),
          const _HelpArticleTile(
            icon: Icons.favorite_border_rounded,
            title: 'Favoritos',
            text:
                'Toque no coração do perfil do prestador para salvar. Seus favoritos ficam acessíveis pelo topo da Home e pela área de Perfil.',
          ),
          const _HelpArticleTile(
            icon: Icons.manage_accounts_outlined,
            title: 'Dados, CPF, telefone e senha',
            text:
                'Entre nas configurações pelo ícone de engrenagem no Perfil para editar dados pessoais. A redefinição de senha fica em uma seção própria.',
          ),
          const _HelpArticleTile(
            icon: Icons.handyman_outlined,
            title: 'Sou prestador',
            text:
                'Complete serviços, disponibilidade, portfólio e experiência na área Colaborador para melhorar a confiança do seu perfil.',
          ),
          const SizedBox(height: 14),
          _ContactCard(
            icon: Icons.mail_outline_rounded,
            title: 'Contato',
            text: 'suporte@buscai.app',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class RateServiceScreen extends ConsumerStatefulWidget {
  final ServiceHistoryItem item;

  const RateServiceScreen({super.key, required this.item});

  @override
  ConsumerState<RateServiceScreen> createState() => _RateServiceScreenState();
}

class _RateServiceScreenState extends ConsumerState<RateServiceScreen> {
  final commentController = TextEditingController();
  int rating = 5;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(sessionProvider.notifier).addUserReview(
          UserServiceReview(
            provider: widget.item.provider,
            service: widget.item.service,
            rating: rating,
            comment: commentController.text.trim(),
            date: 'Hoje',
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return SimplePage(
      title: 'Avaliar serviço',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ServiceSummary(item: item),
          const SizedBox(height: 20),
          const Text('Nota', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                onPressed: () => setState(() => rating = value),
                icon: Icon(
                  value <= rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: BColors.orange,
                  size: 34,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          const Text('Comentário',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(
            icon: Icons.rate_review_outlined,
            hint: 'Conte como foi o atendimento',
            controller: commentController,
          ),
          const SizedBox(height: 22),
          PrimaryButton(label: 'Enviar avaliação', onPressed: _save),
        ],
      ),
    );
  }
}

class UserReviewsHistoryScreen extends ConsumerWidget {
  const UserReviewsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(sessionProvider).userReviews;
    return SimplePage(
      title: 'Minhas avaliações',
      child: reviews.isEmpty
          ? const EmptyPanel(
              icon: Icons.star_border_rounded,
              text:
                  'Suas avaliações aparecerão aqui depois que você avaliar um serviço.',
            )
          : Column(
              children: reviews
                  .map((review) => _UserReviewCard(review: review))
                  .toList(),
            ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final AppUser user;
  final double radius;

  const _UserAvatar({required this.user, required this.radius});

  @override
  Widget build(BuildContext context) {
    final initial =
        user.name.trim().isEmpty ? '?' : user.name.trim()[0].toUpperCase();
    final avatarImage = _userAvatarImage(user.photoUrl);
    return CircleAvatar(
      radius: radius,
      backgroundColor: BColors.paper,
      backgroundImage: avatarImage,
      child: avatarImage == null
          ? Text(
              initial,
              style: TextStyle(
                  color: BColors.green,
                  fontSize: radius * .75,
                  fontWeight: FontWeight.w700),
            )
          : null,
    );
  }

  ImageProvider? _userAvatarImage(String value) {
    if (value.isEmpty) return null;
    if (value.startsWith('data:image')) {
      final commaIndex = value.indexOf(',');
      if (commaIndex == -1) return null;
      return MemoryImage(base64Decode(value.substring(commaIndex + 1)));
    }
    return NetworkImage(value);
  }
}

class _EditableUserAvatar extends StatelessWidget {
  final AppUser user;
  final double radius;
  final VoidCallback onCameraTap;

  const _EditableUserAvatar({
    required this.user,
    required this.radius,
    required this.onCameraTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _UserAvatar(user: user, radius: radius),
        Positioned(
          right: -2,
          bottom: -2,
          child: GestureDetector(
            onTap: onCameraTap,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: BColors.orange,
                shape: BoxShape.circle,
                border: Border.all(color: BColors.paper, width: 3),
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  color: Colors.white, size: 19),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsHeroCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _SettingsHeroCard({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(radius: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: BColors.green,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(text,
                    style: const TextStyle(color: BColors.gray, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationHistoryTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationHistoryTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: cardDecoration(radius: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor:
                  notification.unread ? const Color(0xFFFFF1EA) : BColors.paper,
              child: Icon(notification.icon, color: BColors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notification.title,
                            style:
                                const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      Text(notification.timeLabel,
                          style: const TextStyle(
                              color: BColors.gray, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(notification.message,
                      style: const TextStyle(
                          color: BColors.gray, height: 1.35, fontSize: 13)),
                ],
              ),
            ),
            if (notification.unread) ...[
              const SizedBox(width: 8),
              Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: BColors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HelpArticleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _HelpArticleTile({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: cardDecoration(radius: 14),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: BColors.paper,
            child: Icon(icon, color: BColors.green, size: 19),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(text,
                  style: const TextStyle(color: BColors.gray, height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SwitchCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: cardDecoration(radius: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: BColors.paper,
            child: Icon(icon, color: BColors.green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: BColors.gray, fontSize: 12, height: 1.35)),
              ],
            ),
          ),
          Switch(
              value: value, activeColor: BColors.green, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoCard(
      {required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(radius: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: BColors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(text,
                    style: const TextStyle(color: BColors.gray, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final VoidCallback onTap;

  const _ContactCard(
      {required this.icon,
      required this.title,
      required this.text,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration(radius: 14),
        child: Row(
          children: [
            CircleAvatar(
                radius: 22,
                backgroundColor: BColors.paper,
                child: Icon(icon, color: BColors.green)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(text, style: const TextStyle(color: BColors.gray)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: BColors.gray),
          ],
        ),
      ),
    );
  }
}

class _ServiceSummary extends StatelessWidget {
  final ServiceHistoryItem item;

  const _ServiceSummary({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(radius: 14),
      child: Row(
        children: [
          Avatar(provider: item.provider, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.service.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(item.provider.name,
                    style: const TextStyle(color: BColors.gray)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserReviewCard extends StatelessWidget {
  final UserServiceReview review;

  const _UserReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(review.service.name,
                      style: const TextStyle(fontWeight: FontWeight.w700))),
              ...List.generate(
                5,
                (index) => Icon(
                  index < review.rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: BColors.orange,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${review.provider.name} • ${review.date}',
              style: const TextStyle(color: BColors.gray, fontSize: 12)),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment, style: const TextStyle(height: 1.45)),
          ],
        ],
      ),
    );
  }
}

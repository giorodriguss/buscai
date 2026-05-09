part of '../figma_flow.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _openEditProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => EditUserProfileScreen(user: widget.user)),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() {});
  }

  Future<void> _openReview(ServiceHistoryItem item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RateServiceScreen(item: item)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final favoriteProviders = mockProviders
        .where(
            (provider) => AppSession.favoriteProviderIds.contains(provider.id))
        .toList();
    final history = AppSession.history;
    final reviewCount = AppSession.userReviews.length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 112),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 48, 22, 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [BColors.green, BColors.greenDark],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _UserAvatar(name: user.name, size: 80),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xDDF7F4EF), fontSize: 13),
                        ),
                        if (user.phone.trim().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            user.phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0xBDF7F4EF), fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _openEditProfile,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                          color: BColors.orange, shape: BoxShape.circle),
                      child: const Icon(Icons.settings_outlined,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _ProfileStat(
                          value: '${history.length}', label: 'Servicos')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _ProfileStat(
                          value: '${favoriteProviders.length}',
                          label: 'Favoritos')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _openPage(const MyReviewsScreen()),
                      child: _ProfileStat(
                          value: '$reviewCount', label: 'Avaliacoes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: cardDecoration(radius: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Favoritos',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700)),
                        TextButton(
                          onPressed: () => _openPage(const FavoritesScreen()),
                          child: const Text('Ver todos',
                              style: TextStyle(color: BColors.orange)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (favoriteProviders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Nenhum favorito ainda.',
                            style: TextStyle(color: BColors.gray)),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: favoriteProviders.take(4).map((provider) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: () => openProvider(context, provider),
                                child: Column(
                                  children: [
                                    Avatar(provider: provider, size: 52),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 66,
                                      child: Text(
                                        provider.name.split(' ').first,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const SectionTitle('Historico recente', size: 20),
              const SizedBox(height: 12),
              if (history.isEmpty)
                const EmptyPanel(
                  icon: Icons.history_rounded,
                  text: 'Seu historico aparecera depois de agendar um servico.',
                )
              else
                ...history.map(
                  (item) => _HistoryCard(
                    item: item,
                    review: AppSession.reviewFor(item),
                    onReview: () => _openReview(item),
                  ),
                ),
              const SizedBox(height: 20),
              const SectionTitle('Configuracoes', size: 20),
              const SizedBox(height: 12),
              Container(
                decoration: cardDecoration(radius: 14),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _SettingsRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Editar perfil',
                      onTap: _openEditProfile,
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      icon: Icons.location_on_outlined,
                      label: 'Enderecos salvos',
                      onTap: () => _openPage(const AddressSelectionScreen()),
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      icon: Icons.notifications_none_rounded,
                      label: 'Notificacoes',
                      trailing: _SettingsStatus(AppSession.notificationsEnabled
                          ? 'Ativas'
                          : 'Pausadas'),
                      onTap: () =>
                          _openPage(const NotificationSettingsScreen()),
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      icon: Icons.shield_outlined,
                      label: 'Privacidade e Seguranca',
                      onTap: () => _openPage(const PrivacySecurityScreen()),
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      icon: Icons.star_outline_rounded,
                      label: 'Avaliacoes feitas',
                      trailing: _SettingsStatus('$reviewCount'),
                      onTap: () => _openPage(const MyReviewsScreen()),
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      icon: Icons.help_outline_rounded,
                      label: 'Ajuda e Suporte',
                      onTap: () => _openPage(const HelpSupportScreen()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    AppSession.reset();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, color: BColors.orange),
                  label: const Text('Sair da conta',
                      style: TextStyle(
                          color: BColors.orange, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EditUserProfileScreen extends StatefulWidget {
  final AppUser user;

  const EditUserProfileScreen({super.key, required this.user});

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  final validation = <String>{};

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  String? get emailError {
    final value = emailController.text.trim();
    if (value.isEmpty || _isValidEmail(value)) return null;
    return 'Use um e-mail valido no formato nome@email.com';
  }

  String? get phoneError {
    final value = phoneController.text.trim();
    if (value.isEmpty || _isValidPhone(value)) return null;
    return 'Use o formato 00 90000-0000';
  }

  void _save() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    if (name.isEmpty || email.isEmpty) {
      setState(() => validation.addAll(['name', 'email']));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome e e-mail.')),
      );
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => validation.add('email'));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Use um e-mail valido no formato nome@email.com.')),
      );
      return;
    }
    if (phone.isNotEmpty && !_isValidPhone(phone)) {
      setState(() => validation.add('phone'));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Use telefone no formato 00 90000-0000.')),
      );
      return;
    }
    widget.user
      ..name = name
      ..email = email
      ..phone = phone;
    AppSession.currentUser = widget.user;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColors.paper,
      appBar: const _GreenAppBar(title: 'Editar Perfil'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _UserAvatar(name: nameController.text, size: 112),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                          color: BColors.orange, shape: BoxShape.circle),
                      child:
                          const Icon(Icons.edit_outlined, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const _FieldLabel('Nome completo'),
            TextInputLike(
              icon: Icons.person_outline_rounded,
              hint: 'Nome completo',
              controller: nameController,
              keyboardType: TextInputType.name,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 18),
            const _FieldLabel('E-mail'),
            TextInputLike(
              icon: Icons.mail_outline_rounded,
              hint: 'E-mail',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              errorText: validation.contains('email') ? emailError : null,
              onChanged: (_) => setState(() => validation.add('email')),
            ),
            const SizedBox(height: 18),
            const _FieldLabel('Telefone'),
            TextInputLike(
              icon: Icons.phone_outlined,
              hint: '00 90000-0000',
              controller: phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: const [PhoneInputFormatter()],
              errorText: validation.contains('phone') ? phoneError : null,
              onChanged: (_) => setState(() => validation.add('phone')),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
                label: 'Salvar alteracoes',
                color: BColors.green,
                onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Notificacoes',
      children: [
        _SwitchTile(
          icon: Icons.notifications_active_outlined,
          title: 'Receber notificacoes',
          subtitle: 'Permite avisos importantes do Buscaí.',
          value: AppSession.notificationsEnabled,
          onChanged: (value) =>
              setState(() => AppSession.notificationsEnabled = value),
        ),
        _SwitchTile(
          icon: Icons.handyman_outlined,
          title: 'Atualizacoes de servicos',
          subtitle: 'Status de agendamentos, conclusoes e avaliacoes.',
          value: AppSession.serviceUpdatesEnabled,
          enabled: AppSession.notificationsEnabled,
          onChanged: (value) =>
              setState(() => AppSession.serviceUpdatesEnabled = value),
        ),
        _SwitchTile(
          icon: Icons.local_offer_outlined,
          title: 'Promocoes e novidades',
          subtitle: 'Novas categorias, beneficios e campanhas locais.',
          value: AppSession.promotionsEnabled,
          enabled: AppSession.notificationsEnabled,
          onChanged: (value) =>
              setState(() => AppSession.promotionsEnabled = value),
        ),
      ],
    );
  }
}

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Privacidade e Seguranca',
      children: [
        _SwitchTile(
          icon: Icons.visibility_outlined,
          title: 'Perfil visivel',
          subtitle:
              'Permite que prestadores vejam seu nome ao receber contato.',
          value: AppSession.profileVisible,
          onChanged: (value) =>
              setState(() => AppSession.profileVisible = value),
        ),
        _SwitchTile(
          icon: Icons.location_on_outlined,
          title: 'Compartilhar localizacao',
          subtitle: 'Usa seu bairro para ordenar prestadores mais proximos.',
          value: AppSession.shareLocation,
          onChanged: (value) =>
              setState(() => AppSession.shareLocation = value),
        ),
        _SwitchTile(
          icon: Icons.fingerprint_rounded,
          title: 'Login por biometria',
          subtitle:
              'Prepara o acesso rapido quando houver autenticacao nativa.',
          value: AppSession.biometricLogin,
          onChanged: (value) =>
              setState(() => AppSession.biometricLogin = value),
        ),
        const SizedBox(height: 18),
        Container(
          decoration: cardDecoration(radius: 14),
          clipBehavior: Clip.antiAlias,
          child: _SettingsRow(
            icon: Icons.lock_reset_rounded,
            label: 'Redefinir senha',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
            ),
          ),
        ),
      ],
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final validation = <String>{};

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? get newPasswordError {
    final value = newPasswordController.text;
    if (value.isEmpty || (value.length >= 6 && value.length <= 12)) {
      return null;
    }
    return 'A senha deve ter de 6 a 12 caracteres';
  }

  String? get confirmPasswordError {
    final value = confirmPasswordController.text;
    if (value.isEmpty || value == newPasswordController.text) return null;
    return 'As senhas nao conferem';
  }

  void _savePassword() {
    final current = currentPasswordController.text;
    final next = newPasswordController.text;
    final confirm = confirmPasswordController.text;
    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      setState(() => validation.addAll(['current', 'new', 'confirm']));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos de senha.')),
      );
      return;
    }
    if (next.length < 6 || next.length > 12) {
      setState(() => validation.add('new'));
      return;
    }
    if (next != confirm) {
      setState(() => validation.add('confirm'));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Senha redefinida localmente no prototipo.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Redefinir senha',
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: cardDecoration(radius: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Crie uma nova senha',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Use de 6 a 12 caracteres. Quando houver backend, esta tela chamara o endpoint seguro de troca de senha.',
                style: TextStyle(color: BColors.gray, height: 1.35),
              ),
              const SizedBox(height: 18),
              TextInputLike(
                icon: Icons.lock_outline_rounded,
                hint: 'Senha atual',
                obscure: true,
                controller: currentPasswordController,
                errorText: validation.contains('current') &&
                        currentPasswordController.text.isEmpty
                    ? 'Informe a senha atual'
                    : null,
              ),
              const SizedBox(height: 12),
              TextInputLike(
                icon: Icons.lock_reset_rounded,
                hint: 'Nova senha',
                obscure: true,
                controller: newPasswordController,
                inputFormatters: [LengthLimitingTextInputFormatter(12)],
                errorText: validation.contains('new') ? newPasswordError : null,
                onChanged: (_) => setState(() => validation.add('new')),
              ),
              const SizedBox(height: 12),
              TextInputLike(
                icon: Icons.verified_user_outlined,
                hint: 'Confirmar nova senha',
                obscure: true,
                controller: confirmPasswordController,
                inputFormatters: [LengthLimitingTextInputFormatter(12)],
                errorText: validation.contains('confirm')
                    ? confirmPasswordError
                    : null,
                onChanged: (_) => setState(() => validation.add('confirm')),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                  label: 'Salvar nova senha',
                  color: BColors.green,
                  onPressed: _savePassword),
            ],
          ),
        ),
      ],
    );
  }
}

class RateServiceScreen extends StatefulWidget {
  final ServiceHistoryItem item;

  const RateServiceScreen({super.key, required this.item});

  @override
  State<RateServiceScreen> createState() => _RateServiceScreenState();
}

class _RateServiceScreenState extends State<RateServiceScreen> {
  late int rating;
  late final TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    final currentReview = AppSession.reviewFor(widget.item);
    rating = currentReview?.rating ?? 5;
    commentController =
        TextEditingController(text: currentReview?.comment ?? '');
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void _saveReview() {
    AppSession.saveReview(
      UserServiceReview(
        item: widget.item,
        rating: rating,
        comment: commentController.text.trim(),
        reviewedAt: 'Hoje',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliacao salva com sucesso.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return _SettingsScaffold(
      title: 'Avaliar servico',
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: cardDecoration(radius: 14),
          child: Row(
            children: [
              Avatar(provider: item.provider, size: 54),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.service.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('${item.provider.name} - ${item.provider.category}',
                        style:
                            const TextStyle(color: BColors.gray, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(item.date,
                        style:
                            const TextStyle(color: BColors.gray, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: cardDecoration(radius: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Como foi o atendimento?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Center(
                child: _RatingSelector(
                  rating: rating,
                  onChanged: (value) => setState(() => rating = value),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: commentController,
                minLines: 4,
                maxLines: 6,
                style: const TextStyle(fontFamily: 'Georgia'),
                decoration: InputDecoration(
                  hintText: 'Conte como foi sua experiencia',
                  hintStyle: const TextStyle(fontFamily: 'Georgia'),
                  filled: true,
                  fillColor: BColors.paper,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: BColors.border, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: BColors.border, width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: BColors.orange, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                  label: 'Enviar avaliacao',
                  color: BColors.orange,
                  onPressed: _saveReview),
            ],
          ),
        ),
      ],
    );
  }
}

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = AppSession.userReviews;
    return _SettingsScaffold(
      title: 'Avaliacoes feitas',
      children: [
        if (reviews.isEmpty)
          const EmptyPanel(
            icon: Icons.star_border_rounded,
            text: 'Suas avaliacoes aparecerao aqui depois dos atendimentos.',
          )
        else
          ...reviews.map((review) => _UserReviewCard(review: review)),
      ],
    );
  }
}

class _UserReviewCard extends StatelessWidget {
  final UserServiceReview review;

  const _UserReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final item = review.item;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(radius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Avatar(provider: item.provider, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.service.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(item.provider.name,
                        overflow: TextOverflow.ellipsis,
                        style:
                            const TextStyle(color: BColors.gray, fontSize: 12)),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: BColors.orange,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(review.comment, style: const TextStyle(height: 1.4)),
          ],
          const SizedBox(height: 10),
          Text('Avaliado em ${review.reviewedAt}',
              style: const TextStyle(color: BColors.gray, fontSize: 12)),
        ],
      ),
    );
  }
}

class _RatingSelector extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onChanged;

  const _RatingSelector({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final value = index + 1;
        return IconButton(
          onPressed: () => onChanged(value),
          iconSize: 38,
          color: BColors.orange,
          icon: Icon(
            value <= rating ? Icons.star_rounded : Icons.star_border_rounded,
          ),
        );
      }),
    );
  }
}

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _SettingsScaffold(
      title: 'Ajuda e Suporte',
      children: [
        const _HelpCard(
          icon: Icons.calendar_today_outlined,
          title: 'Como agendar um servico?',
          text:
              'Escolha um prestador, selecione o servico, data e horario, depois toque em agendar ou chamar no WhatsApp.',
        ),
        const _HelpCard(
          icon: Icons.star_outline_rounded,
          title: 'Como avaliar um atendimento?',
          text:
              'Depois que o servico for marcado como concluido, a avaliacao fica disponivel no seu historico.',
        ),
        const _HelpCard(
          icon: Icons.payment_outlined,
          title: 'Pagamentos',
          text:
              'Nesta versao do prototipo, valores sao informativos e a combinacao final acontece direto com o prestador.',
        ),
        const SizedBox(height: 12),
        PrimaryButton(
          label: 'Falar com suporte',
          icon: Icons.chat_bubble_outline_rounded,
          color: BColors.orange,
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Canal de suporte preparado para integracao.')),
          ),
        ),
      ],
    );
  }
}

class _SettingsScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsScaffold({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColors.paper,
      appBar: _GreenAppBar(title: title),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: children,
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : .55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
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
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: BColors.gray, fontSize: 13, height: 1.35)),
                ],
              ),
            ),
            Switch(
              value: value,
              activeThumbColor: BColors.green,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsStatus extends StatelessWidget {
  final String text;

  const _SettingsStatus(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(color: BColors.gray, fontSize: 12));
  }
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _HelpCard(
      {required this.icon, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(radius: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
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

class _UserAvatar extends StatelessWidget {
  final String name;
  final double size;

  const _UserAvatar({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: BColors.paper,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: size >= 100 ? 4 : 0),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: BColors.green,
            fontSize: size * .38,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

part of '../figma_flow.dart';

class EditUserProfileScreen extends ConsumerStatefulWidget {
  final AppUser user;

  const EditUserProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends ConsumerState<EditUserProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController photoController;
  late final TextEditingController neighborhoodController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    photoController = TextEditingController(text: widget.user.photoUrl);
    neighborhoodController = TextEditingController(text: widget.user.neighborhood);
  }

  @override
  void dispose() {
    nameController.dispose();
    photoController.dispose();
    neighborhoodController.dispose();
    super.dispose();
  }

  void _save() {
    final user = widget.user;
    user.name = nameController.text.trim().isEmpty ? user.name : nameController.text.trim();
    user.photoUrl = photoController.text.trim();
    user.neighborhood = neighborhoodController.text.trim();
    ref.read(sessionProvider.notifier).setUser(user);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final preview = AppUser(
      id: widget.user.id,
      name: nameController.text.trim().isEmpty ? widget.user.name : nameController.text.trim(),
      email: widget.user.email,
      phone: widget.user.phone,
      photoUrl: photoController.text.trim(),
      neighborhood: neighborhoodController.text.trim(),
      isProvider: widget.user.isProvider,
    );
    return Scaffold(
      backgroundColor: BColors.paper,
      appBar: const _GreenAppBar(title: 'Editar perfil'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
        children: [
          Center(child: _UserAvatar(user: preview, radius: 48)),
          const SizedBox(height: 20),
          const Text('Nome', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(icon: Icons.person_outline_rounded, hint: 'Nome', controller: nameController),
          const SizedBox(height: 18),
          const Text('Foto', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(
            icon: Icons.image_outlined,
            hint: 'URL da foto',
            controller: photoController,
            keyboardType: TextInputType.url,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),
          const Text('Bairro', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(
            icon: Icons.location_city_outlined,
            hint: 'Seu bairro',
            controller: neighborhoodController,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
          PrimaryButton(label: 'Salvar alteracoes', onPressed: _save),
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
    return SimplePage(
      title: 'Notificacoes',
      child: Column(
        children: [
          _SwitchCard(
            icon: Icons.notifications_active_outlined,
            title: 'Alertas do app',
            subtitle: 'Ativar ou desativar notificacoes gerais.',
            value: session.notificationsEnabled,
            onChanged: notifier.setNotificationsEnabled,
          ),
          _SwitchCard(
            icon: Icons.calendar_month_outlined,
            title: 'Alertas de servico',
            subtitle: 'Receber lembretes sobre agendamentos e atendimentos.',
            value: session.serviceAlertsEnabled,
            onChanged: session.notificationsEnabled ? notifier.setServiceAlertsEnabled : null,
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
        children: [
          _SwitchCard(
            icon: Icons.visibility_outlined,
            title: 'Perfil visivel',
            subtitle: 'Permitir que seu perfil apareca nas areas publicas do app.',
            value: session.profileVisible,
            onChanged: notifier.setProfileVisible,
          ),
          _SwitchCard(
            icon: Icons.analytics_outlined,
            title: 'Uso de dados',
            subtitle: 'Autorizar uso de dados para melhorar recomendacoes.',
            value: session.dataSharingEnabled,
            onChanged: notifier.setDataSharingEnabled,
          ),
          const SizedBox(height: 12),
          const _InfoCard(
            icon: Icons.shield_outlined,
            title: 'Seguranca da conta',
            text: 'Dados sensiveis e alteracoes de seguranca dependem da integracao com o backend.',
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
  String? error;

  @override
  void dispose() {
    currentController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final passwordError = FormValidators.password(passwordController.text);
    final confirmError = FormValidators.confirmPassword(confirmController.text, passwordController.text);
    setState(() => error = passwordError ?? confirmError);
    if (error != null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redefinicao de senha pendente de integracao com o backend.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimplePage(
      title: 'Redefinir senha',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextInputLike(icon: Icons.lock_outline_rounded, hint: 'Senha atual', controller: currentController, obscure: true),
          const SizedBox(height: 12),
          TextInputLike(icon: Icons.lock_reset_rounded, hint: 'Nova senha', controller: passwordController, obscure: true, errorText: error),
          const SizedBox(height: 12),
          TextInputLike(icon: Icons.lock_reset_rounded, hint: 'Confirmar nova senha', controller: confirmController, obscure: true),
          const SizedBox(height: 18),
          const _InfoCard(
            icon: Icons.info_outline_rounded,
            title: 'Pendente de backend',
            text: 'Esta tela ja valida os campos, mas ainda nao envia a alteracao para a API.',
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Atualizar senha', onPressed: _submit),
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
        children: [
          const _FaqTile(
            question: 'Como encontro um prestador?',
            answer: 'Use a busca por categoria, bairro ou nome do servico e abra o perfil para ver detalhes.',
          ),
          const _FaqTile(
            question: 'Como remarco um atendimento?',
            answer: 'Por enquanto, combine diretamente com o prestador pelo WhatsApp.',
          ),
          const _FaqTile(
            question: 'Como viro prestador?',
            answer: 'Crie uma conta de prestador e complete seu perfil na aba Colaborador.',
          ),
          const SizedBox(height: 14),
          _ContactCard(
            icon: Icons.mail_outline_rounded,
            title: 'Contato',
            text: 'suporte@buscai.app',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contato pendente de integracao.')),
            ),
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avaliacao salva.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return SimplePage(
      title: 'Avaliar servico',
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
                  value <= rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: BColors.orange,
                  size: 34,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          const Text('Comentario', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          TextInputLike(
            icon: Icons.rate_review_outlined,
            hint: 'Conte como foi o atendimento',
            controller: commentController,
          ),
          const SizedBox(height: 22),
          PrimaryButton(label: 'Enviar avaliacao', onPressed: _save),
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
      title: 'Minhas avaliacoes',
      child: reviews.isEmpty
          ? const EmptyPanel(
              icon: Icons.star_border_rounded,
              text: 'Suas avaliacoes aparecerao aqui depois que voce avaliar um servico.',
            )
          : Column(
              children: reviews.map((review) => _UserReviewCard(review: review)).toList(),
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
    final initial = user.name.trim().isEmpty ? '?' : user.name.trim()[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: BColors.paper,
      backgroundImage: user.photoUrl.isEmpty ? null : NetworkImage(user.photoUrl),
      child: user.photoUrl.isEmpty
          ? Text(
              initial,
              style: TextStyle(color: BColors.green, fontSize: radius * .75, fontWeight: FontWeight.w700),
            )
          : null,
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: BColors.gray, fontSize: 12, height: 1.35)),
              ],
            ),
          ),
          Switch(value: value, activeColor: BColors.green, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoCard({required this.icon, required this.title, required this.text});

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
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(text, style: const TextStyle(color: BColors.gray, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: cardDecoration(radius: 14),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.w700)),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(answer, style: const TextStyle(color: BColors.gray, height: 1.4)),
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

  const _ContactCard({required this.icon, required this.title, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration(radius: 14),
        child: Row(
          children: [
            CircleAvatar(radius: 22, backgroundColor: BColors.paper, child: Icon(icon, color: BColors.green)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
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
                Text(item.service.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(item.provider.name, style: const TextStyle(color: BColors.gray)),
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
              Expanded(child: Text(review.service.name, style: const TextStyle(fontWeight: FontWeight.w700))),
              ...List.generate(
                5,
                (index) => Icon(
                  index < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: BColors.orange,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('${review.provider.name} • ${review.date}', style: const TextStyle(color: BColors.gray, fontSize: 12)),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment, style: const TextStyle(height: 1.45)),
          ],
        ],
      ),
    );
  }
}

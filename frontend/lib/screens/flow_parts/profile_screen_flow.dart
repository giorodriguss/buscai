part of '../figma_flow.dart';

class ProfileScreen extends ConsumerWidget {
  final AppUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final activeUser = session.currentUser ?? user;
    final favoriteProviders = mockProviders
        .where((provider) => session.favoriteProviderIds.contains(provider.id))
        .toList();
    final history = session.history;
    final reviews = session.userReviews;
    final completedServices = session.scheduledServices
        .where((service) =>
            service.status == ScheduledServiceStatus.completed ||
            service.status == ScheduledServiceStatus.reviewed)
        .length;
    return ListView(
      padding: const EdgeInsets.only(bottom: 112),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 48, 22, 28),
          color: BColors.green,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                AccountSettingsScreen(user: activeUser)),
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                            color: BColors.orange, shape: BoxShape.circle),
                        child: const Icon(Icons.settings_outlined,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      _UserAvatar(user: activeUser, radius: 58),
                      const SizedBox(height: 14),
                      Column(
                        children: [
                          Text(_displayProfileName(activeUser.name),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(activeUser.email,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xCCFFFFFF),
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      if (activeUser.neighborhood.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(activeUser.neighborhood,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xCCFFFFFF))),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                      child: _ProfileStat(
                          value: '$completedServices', label: 'Serviços')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _ProfileStat(
                          value: '${favoriteProviders.length}',
                          label: 'Favoritos')),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _ProfileStat(
                          value: '${reviews.length}', label: 'Avaliações')),
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
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const FavoritesScreen()),
                          ),
                          child: const Text('Ver todos',
                              style: TextStyle(color: BColors.orange)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    if (favoriteProviders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Nenhum favorito ainda.',
                            style: TextStyle(color: BColors.gray)),
                      )
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 16,
                          runSpacing: 14,
                          children: favoriteProviders.take(4).map((p) {
                            return SizedBox(
                              width: 64,
                              child: Column(
                                children: [
                                  Avatar(provider: p, size: 52),
                                  const SizedBox(height: 8),
                                  Text(
                                    p.name.split(' ').first,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const SectionTitle('Histórico recente', size: 20),
              const SizedBox(height: 12),
              if (history.isEmpty)
                const EmptyPanel(
                  icon: Icons.history_rounded,
                  text: 'Seu histórico aparecerá depois de agendar um serviço.',
                )
              else
                ...history.map(
                  (item) => _HistoryCard(
                    item: item,
                    onRate: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => RateServiceScreen(item: item)),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const SectionTitle('Configurações', size: 20),
              const SizedBox(height: 12),
              Container(
                decoration: cardDecoration(radius: 14),
                child: Column(
                  children: [
                    _SettingsRow(
                      icon: Icons.location_on_outlined,
                      label: 'Endereços salvos',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AddressSelectionScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      icon: Icons.notifications_none_rounded,
                      label: 'Notificações',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const NotificationSettingsScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      icon: Icons.shield_outlined,
                      label: 'Privacidade e segurança',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const PrivacySecurityScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      icon: Icons.star_border_rounded,
                      label: 'Minhas avaliações',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const UserReviewsHistoryScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsRow(
                      icon: Icons.help_outline_rounded,
                      label: 'Ajuda e suporte',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const HelpSupportScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(sessionProvider.notifier).reset();
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

String _displayProfileName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.length <= 2) return name.trim();
  return '${parts.first} ${parts.last}';
}

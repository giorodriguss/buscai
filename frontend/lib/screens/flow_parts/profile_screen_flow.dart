part of '../figma_flow.dart';

<<<<<<< HEAD
class ProfileScreen extends ConsumerWidget {
=======
class ProfileScreen extends StatelessWidget {
>>>>>>> origin/develop
  final AppUser user;

  const ProfileScreen({super.key, required this.user});

  @override
<<<<<<< HEAD
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final favoriteProviders = mockProviders
        .where((provider) => session.favoriteProviderIds.contains(provider.id))
        .toList();
    final history = session.history;
=======
  Widget build(BuildContext context) {
    final favoriteProviders = mockProviders
        .where((provider) => AppSession.favoriteProviderIds.contains(provider.id))
        .toList();
    final history = AppSession.history;
>>>>>>> origin/develop
    return ListView(
      padding: const EdgeInsets.only(bottom: 112),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 48, 22, 28),
          color: BColors.green,
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: BColors.paper,
                    child: Text(
                      user.name.trim().isEmpty ? '?' : user.name.trim()[0].toUpperCase(),
                      style: const TextStyle(color: BColors.green, fontSize: 30, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(user.email, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: BColors.orange, shape: BoxShape.circle),
                    child: const Icon(Icons.settings_outlined, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _ProfileStat(value: '${history.length}', label: 'Serviços')),
                  const SizedBox(width: 12),
                  Expanded(child: _ProfileStat(value: '${favoriteProviders.length}', label: 'Favoritos')),
                  const SizedBox(width: 12),
                  const Expanded(child: _ProfileStat(value: '0', label: 'Avaliações')),
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Favoritos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('Ver todos', style: TextStyle(color: BColors.orange)),
                      ],
                    ),
                    const SizedBox(height: 22),
                    if (favoriteProviders.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Nenhum favorito ainda.', style: TextStyle(color: BColors.gray)),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: favoriteProviders.take(4).map((p) {
                          return Column(
                            children: [
                              Avatar(provider: p, size: 52),
                              const SizedBox(height: 8),
                              Text(p.name.split(' ').first, style: const TextStyle(fontSize: 12)),
                            ],
                          );
                        }).toList(),
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
                ...history.map((item) => _HistoryCard(item: item)),
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
                        MaterialPageRoute(builder: (_) => const AddressSelectionScreen()),
                      ),
                    ),
                    const Divider(height: 1),
                    const _SettingsRow(icon: Icons.notifications_none_rounded, label: 'Notificações'),
                    const Divider(height: 1),
                    const _SettingsRow(icon: Icons.shield_outlined, label: 'Privacidade e Segurança'),
                    const Divider(height: 1),
                    const _SettingsRow(icon: Icons.help_outline_rounded, label: 'Ajuda e Suporte'),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              Center(
                child: TextButton.icon(
                  onPressed: () {
<<<<<<< HEAD
                    ref.read(sessionProvider.notifier).reset();
=======
                    AppSession.reset();
>>>>>>> origin/develop
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  },
                  icon: const Icon(Icons.logout_rounded, color: BColors.orange),
                  label: const Text('Sair da conta', style: TextStyle(color: BColors.orange, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

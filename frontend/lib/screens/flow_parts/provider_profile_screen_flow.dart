part of '../figma_flow.dart';

<<<<<<< HEAD
class ProviderProfileScreen extends ConsumerStatefulWidget {
=======
class ProviderProfileScreen extends StatefulWidget {
>>>>>>> origin/develop
  final Provider provider;

  const ProviderProfileScreen({super.key, required this.provider});

  @override
<<<<<<< HEAD
  ConsumerState<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen> {
=======
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  bool favorite = false;
>>>>>>> origin/develop
  String? selectedService;
  String? selectedHour;
  int selectedDate = 0;

<<<<<<< HEAD
=======
  @override
  void initState() {
    super.initState();
    favorite = AppSession.favoriteProviderIds.contains(widget.provider.id);
  }

>>>>>>> origin/develop
  void _handlePrimaryAction() {
    final provider = widget.provider;
    Service? service;
    for (final item in provider.services) {
      if (item.id == selectedService) {
        service = item;
        break;
      }
    }
    if (service != null && selectedHour != null) {
<<<<<<< HEAD
      ref.read(sessionProvider.notifier).addHistoryItem(
=======
      AppSession.history.insert(
        0,
>>>>>>> origin/develop
        ServiceHistoryItem(
          provider: provider,
          service: service,
          date: 'Hoje, $selectedHour',
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${service.name} agendado para $selectedHour.')),
      );
      setState(() {
        selectedService = null;
        selectedHour = null;
      });
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrindo WhatsApp de ${provider.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
<<<<<<< HEAD
    final isFav = ref.watch(sessionProvider).favoriteProviderIds.contains(provider.id);
=======
>>>>>>> origin/develop

    return Scaffold(
      backgroundColor: BColors.paper,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: 256,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(provider.coverImage, fit: BoxFit.cover),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x66000000), Color(0x99000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                child: CircleButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).pop(),
                  white: true,
                ),
              ),
              Positioned(
                bottom: -64,
                left: 20,
                child: Avatar(provider: provider, size: 128),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 84, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: const TextStyle(
                    color: BColors.black,
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.category.toUpperCase(),
                  style: const TextStyle(
                    color: BColors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 17, color: BColors.gray),
                    const SizedBox(width: 4),
                    Text('${provider.distance} de você', style: const TextStyle(color: BColors.gray)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border.symmetric(horizontal: BorderSide(color: BColors.border)),
                  ),
                  child: Row(
                    children: [
                      StatPill(
                        icon: Icons.star_rounded,
                        iconColor: BColors.orange,
                        value: '${provider.rating}',
                        label: '${provider.reviewCount} avaliações',
                      ),
                      const SizedBox(width: 24),
                      StatPill(
                        icon: Icons.emoji_events_rounded,
                        iconColor: BColors.green,
                        value: '${provider.yearsExperience} ${provider.yearsExperience == 1 ? 'ano' : 'anos'}',
                        label: 'Experiência',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: selectedService != null && selectedHour != null
                            ? 'Agendar $selectedHour'
                            : 'Chamar no WhatsApp',
                        icon: Icons.chat_bubble_outline_rounded,
                        onPressed: _handlePrimaryAction,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
<<<<<<< HEAD
                      onTap: () => ref.read(sessionProvider.notifier).toggleFavorite(provider.id),
=======
                      onTap: () => setState(() {
                        favorite = !favorite;
                        if (favorite) {
                          AppSession.favoriteProviderIds.add(provider.id);
                        } else {
                          AppSession.favoriteProviderIds.remove(provider.id);
                        }
                      }),
>>>>>>> origin/develop
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
<<<<<<< HEAD
                          color: isFav ? BColors.orange : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isFav ? BColors.orange : BColors.green,
=======
                          color: favorite ? BColors.orange : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: favorite ? BColors.orange : BColors.green,
>>>>>>> origin/develop
                            width: 2,
                          ),
                        ),
                        child: Icon(
<<<<<<< HEAD
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? Colors.white : BColors.green,
=======
                          favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: favorite ? Colors.white : BColors.green,
>>>>>>> origin/develop
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const SectionTitle('Sobre', size: 18),
                const SizedBox(height: 10),
                Text(
                  provider.about,
                  style: const TextStyle(color: BColors.black, height: 1.45),
                ),
                if (provider.services.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const SectionTitle('Serviços', size: 18),
                  const SizedBox(height: 14),
                  ...provider.services.map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ServiceOption(
                        service: service,
                        selected: selectedService == service.id,
                        onTap: () => setState(() {
                          selectedService = selectedService == service.id ? null : service.id;
                        }),
                      ),
                    ),
                  ),
                ],
                if (provider.availableHours.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  BookingPicker(
                    hours: provider.availableHours,
                    selectedDate: selectedDate,
                    selectedHour: selectedHour,
                    onDate: (index) => setState(() => selectedDate = index),
                    onHour: (hour) => setState(() {
                      selectedHour = selectedHour == hour ? null : hour;
                    }),
                  ),
                ],
                if (provider.portfolio.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const SectionTitle('Portfólio', size: 18),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.portfolio.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (_, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(provider.portfolio[index], fit: BoxFit.cover),
                    ),
                  ),
                ],
                if (provider.reviews.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const SectionTitle('Avaliações', size: 18),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AllReviewsScreen(provider: provider),
                          ),
                        ),
                        child: const Text('Ver todas'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...provider.reviews.take(2).map((r) => ReviewCard(review: r)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AllReviewsScreen extends StatelessWidget {
  final Provider provider;

  const AllReviewsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SimplePage(
      title: 'Avaliações',
      child: Column(
        children: provider.reviews.map((r) => ReviewCard(review: r)).toList(),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      title: 'Notificações',
      child: EmptyPanel(
        icon: Icons.notifications_none_rounded,
        text: 'Nenhuma notificação por enquanto.',
      ),
    );
  }
}
<<<<<<< HEAD
=======

// Perfil do usuario comum. Favoritos, historico e enderecos vem da AppSession,
// entao qualquer acao feita no front aparece aqui na mesma sessao.
>>>>>>> origin/develop

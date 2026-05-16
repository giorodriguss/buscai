part of '../figma_flow.dart';

class ProviderProfileScreen extends ConsumerStatefulWidget {
  final Provider provider;

  const ProviderProfileScreen({super.key, required this.provider});

  @override
  ConsumerState<ProviderProfileScreen> createState() =>
      _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen> {
  String? selectedService;
  String? selectedHour;
  int selectedDate = 0;

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
      final bookingDate = BookingPicker._dates[selectedDate];
      final dateLabel = bookingDate.caption.isNotEmpty
          ? '${bookingDate.caption}, ${bookingDate.day}'
          : '${bookingDate.weekDay} ${bookingDate.day}';
      // Futuro backend: criar appointment e abrir WhatsApp com link retornado
      // ou montado pelo backend. Hoje o agendamento fica local em SessionState.
      ref.read(sessionProvider.notifier).addScheduledService(
            ScheduledService(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              provider: provider,
              service: service,
              date: dateLabel,
              hour: selectedHour!,
            ),
          );
      ref.read(sessionProvider.notifier).addHistoryItem(
            ServiceHistoryItem(
              provider: provider,
              service: service,
              date: '$dateLabel, $selectedHour',
            ),
          );
      setState(() {
        selectedService = null;
        selectedHour = null;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final session = ref.watch(sessionProvider);
    final isFav = session.favoriteProviderIds.contains(provider.id);
    // Futuro backend: reviews devem vir de GET /providers/:id/reviews.
    // As avaliacoes locais simulam o fluxo ate existir persistencia real.
    final localReviews = session.userReviews
        .where((review) => review.provider.id == provider.id)
        .map(
          (review) => Review(
            name: session.currentUser?.name ?? 'Você',
            rating: review.rating,
            comment: review.comment,
            date: review.date,
          ),
        )
        .toList();
    final visibleReviews = [...localReviews, ...provider.reviews];

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
                    const Icon(Icons.location_on_outlined,
                        size: 17, color: BColors.gray),
                    const SizedBox(width: 4),
                    Text('${provider.distance} de você',
                        style: const TextStyle(color: BColors.gray)),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    border: Border.symmetric(
                        horizontal: BorderSide(color: BColors.border)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      StatPill(
                        icon: Icons.star_rounded,
                        iconColor: BColors.orange,
                        value: '${provider.rating}',
                        label: '${visibleReviews.length} avaliações',
                      ),
                      const SizedBox(width: 24),
                      StatPill(
                        icon: Icons.emoji_events_rounded,
                        iconColor: BColors.green,
                        value:
                            '${provider.yearsExperience} ${provider.yearsExperience == 1 ? 'ano' : 'anos'}',
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
                      onTap: () => ref
                          .read(sessionProvider.notifier)
                          .toggleFavorite(provider.id),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isFav ? BColors.orange : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isFav ? BColors.orange : BColors.green,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFav ? Colors.white : BColors.green,
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
                          selectedService =
                              selectedService == service.id ? null : service.id;
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (_, index) => ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(provider.portfolio[index],
                          fit: BoxFit.cover),
                    ),
                  ),
                ],
                if (visibleReviews.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const SectionTitle('Avaliações', size: 18),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AllReviewsScreen(
                              provider: provider,
                              reviews: visibleReviews,
                            ),
                          ),
                        ),
                        child: const Text('Ver todas'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...visibleReviews.take(2).map((r) => ReviewCard(review: r)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AllReviewsScreen extends StatefulWidget {
  final Provider provider;
  final List<Review>? reviews;

  const AllReviewsScreen({super.key, required this.provider, this.reviews});

  @override
  State<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends State<AllReviewsScreen> {
  int? selectedStars;
  bool recentFirst = true;

  List<Review> get filteredReviews {
    final source = [...(widget.reviews ?? widget.provider.reviews)];
    final filtered = selectedStars == null
        ? source
        : source.where((review) => review.rating == selectedStars).toList();
    return recentFirst ? filtered : filtered.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final reviews = filteredReviews;
    return SimplePage(
      title: 'Avaliações',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: cardDecoration(radius: 14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ReviewFilterPill(
                        label: 'Mais recentes',
                        icon: Icons.schedule_rounded,
                        selected: recentFirst,
                        onTap: () => setState(() => recentFirst = true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ReviewFilterPill(
                        label: 'Mais antigas',
                        icon: Icons.history_rounded,
                        selected: !recentFirst,
                        onTap: () => setState(() => recentFirst = false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ReviewFilterPill(
                        label: 'Todas',
                        icon: Icons.star_border_rounded,
                        selected: selectedStars == null,
                        onTap: () => setState(() => selectedStars = null),
                      ),
                      const SizedBox(width: 8),
                      ...List.generate(5, (index) {
                        final stars = 5 - index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _ReviewFilterPill(
                            label: '$stars',
                            icon: Icons.star_rounded,
                            selected: selectedStars == stars,
                            onTap: () => setState(() {
                              selectedStars =
                                  selectedStars == stars ? null : stars;
                            }),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (reviews.isEmpty)
            const EmptyPanel(
              icon: Icons.star_border_rounded,
              text: 'Nenhuma avaliação encontrada para esse filtro.',
            )
          else
            ...reviews.map((r) => ReviewCard(review: r)),
        ],
      ),
    );
  }
}

class _ReviewFilterPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ReviewFilterPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? BColors.green : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? BColors.green : BColors.border,
              width: 1.3,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: selected ? Colors.white : BColors.orange),
              const SizedBox(width: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : BColors.black,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
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

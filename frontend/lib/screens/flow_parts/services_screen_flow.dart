part of '../figma_flow.dart';

// Tela local de acompanhamento dos serviços do morador/prestador.
// Futuro backend: substituir session.scheduledServices por GET /appointments
// e trocar as ações abaixo por PATCH/POST de status e avaliação.
class ServicesScreen extends ConsumerStatefulWidget {
  final bool isProviderView;

  const ServicesScreen({super.key, required this.isProviderView});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  ScheduledServiceStatus? selectedFilter;

  List<ScheduledService> _filtered(List<ScheduledService> services) {
    if (selectedFilter == null) return services;
    return services
        .where((service) => service.status == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(sessionProvider).scheduledServices;
    final visibleServices = _filtered(services);
    final pendingCount = services
        .where((s) => s.status == ScheduledServiceStatus.pending)
        .length;
    final completedCount = services
        .where((s) => s.status == ScheduledServiceStatus.completed)
        .length;
    final reviewedCount = services
        .where((s) => s.status == ScheduledServiceStatus.reviewed)
        .length;

    return Scaffold(
      backgroundColor: BColors.paper,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 28, 20, 28),
            color: BColors.green,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Meus Serviços',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                        child: _ServiceFilterCard(
                            label: 'Todos',
                            count: services.length,
                            active: selectedFilter == null,
                            onTap: () =>
                                setState(() => selectedFilter = null))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _ServiceFilterCard(
                            label: 'Pendente',
                            count: pendingCount,
                            active: selectedFilter ==
                                ScheduledServiceStatus.pending,
                            onTap: () => setState(() => selectedFilter =
                                ScheduledServiceStatus.pending))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _ServiceFilterCard(
                            label: 'Realizado',
                            count: completedCount,
                            active: selectedFilter ==
                                ScheduledServiceStatus.completed,
                            onTap: () => setState(() => selectedFilter =
                                ScheduledServiceStatus.completed))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _ServiceFilterCard(
                            label: 'Avaliado',
                            count: reviewedCount,
                            active: selectedFilter ==
                                ScheduledServiceStatus.reviewed,
                            onTap: () => setState(() => selectedFilter =
                                ScheduledServiceStatus.reviewed))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: visibleServices.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(32, 0, 32, 88),
                      child: EmptyPanel(
                        icon: Icons.assignment_outlined,
                        text:
                            'Seus serviços aparecerão aqui depois de agendar com um prestador.',
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 112),
                    itemCount: visibleServices.length,
                    itemBuilder: (context, index) => _ScheduledServiceCard(
                      service: visibleServices[index],
                      isProviderView: widget.isProviderView,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ServiceFilterCard extends StatelessWidget {
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  const _ServiceFilterCard({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: active ? BColors.orange : Colors.white, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$count',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            FittedBox(child: Text(label, style: const TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }
}

class _ScheduledServiceCard extends ConsumerWidget {
  final ScheduledService service;
  final bool isProviderView;

  const _ScheduledServiceCard({
    required this.service,
    required this.isProviderView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(radius: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Avatar(provider: service.provider, size: 58),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        service.service.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                    _StatusBadge(service: service),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${service.provider.name} • ${service.provider.category}',
                  style: const TextStyle(color: BColors.gray),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 15, color: BColors.gray),
                    const SizedBox(width: 5),
                    Text(service.date,
                        style: const TextStyle(color: BColors.gray)),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time_rounded,
                        size: 16, color: BColors.gray),
                    const SizedBox(width: 5),
                    Text(service.hour,
                        style: const TextStyle(color: BColors.gray)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'R\$ ${service.service.price}',
                      style: const TextStyle(
                          color: BColors.green,
                          fontSize: 17,
                          fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    _ServiceAction(
                        service: service, isProviderView: isProviderView),
                  ],
                ),
                if (service.status == ScheduledServiceStatus.reviewed) ...[
                  const SizedBox(height: 12),
                  _ReviewedPreview(service: service),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ScheduledService service;

  const _StatusBadge({required this.service});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (service.status) {
      ScheduledServiceStatus.pending => (
          service.waitingResidentConfirmation ? 'Confirmar' : 'Pendente',
          const Color(0xFFFFF8D9),
        ),
      ScheduledServiceStatus.completed => (
          'Realizado',
          const Color(0xFFEAF2FF)
        ),
      ScheduledServiceStatus.reviewed => ('Avaliado', const Color(0xFFEAF8EF)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class _ServiceAction extends ConsumerWidget {
  final ScheduledService service;
  final bool isProviderView;

  const _ServiceAction({required this.service, required this.isProviderView});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(sessionProvider.notifier);

    if (service.status == ScheduledServiceStatus.reviewed) {
      return const SizedBox.shrink();
    }

    if (service.status == ScheduledServiceStatus.completed) {
      return _MiniActionButton(
        label: 'Avaliar',
        icon: Icons.star_border_rounded,
        color: BColors.orange,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => RateScheduledServiceScreen(service: service)),
        ),
      );
    }

    if (service.waitingResidentConfirmation && !isProviderView) {
      return _MiniActionButton(
        label: 'Confirmar',
        icon: Icons.check_circle_outline_rounded,
        color: BColors.green,
        onTap: () => notifier.markScheduledServiceCompleted(service.id),
      );
    }

    if (service.waitingResidentConfirmation && isProviderView) {
      return const Text('Aguardando',
          style: TextStyle(color: BColors.gray, fontWeight: FontWeight.w700));
    }

    return _MiniActionButton(
      label: isProviderView ? 'Realizado' : 'Concluído',
      icon: Icons.check_circle_outline_rounded,
      color: BColors.green,
      onTap: () {
        if (isProviderView) {
          notifier.markScheduledServiceWaitingConfirmation(service.id);
        } else {
          notifier.markScheduledServiceCompleted(service.id);
        }
      },
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MiniActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(13)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 17),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _ReviewedPreview extends StatelessWidget {
  final ScheduledService service;

  const _ReviewedPreview({required this.service});

  @override
  Widget build(BuildContext context) {
    final rating = service.rating ?? 5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
              color: const Color(0xFFEAF8EF),
              borderRadius: BorderRadius.circular(999)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                color: BColors.orange,
                size: 18,
              ),
            ),
          ),
        ),
        if ((service.reviewComment ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: BColors.paper, borderRadius: BorderRadius.circular(10)),
            child: Text('"${service.reviewComment}"'),
          ),
        ],
      ],
    );
  }
}

class RateScheduledServiceScreen extends ConsumerStatefulWidget {
  final ScheduledService service;

  const RateScheduledServiceScreen({super.key, required this.service});

  @override
  ConsumerState<RateScheduledServiceScreen> createState() =>
      _RateScheduledServiceScreenState();
}

class _RateScheduledServiceScreenState
    extends ConsumerState<RateScheduledServiceScreen> {
  final commentController = TextEditingController();
  int rating = 5;

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void _saveReview() {
    ref.read(sessionProvider.notifier).reviewScheduledService(
          widget.service.id,
          rating,
          commentController.text.trim(),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SimplePage(
      title: 'Avaliar serviço',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScheduledReviewSummary(service: widget.service),
          const SizedBox(height: 22),
          const Text('Nota', style: TextStyle(fontWeight: FontWeight.w800)),
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
              style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          TextInputLike(
            icon: Icons.rate_review_outlined,
            hint: 'Conte como foi o atendimento',
            controller: commentController,
          ),
          const SizedBox(height: 22),
          PrimaryButton(label: 'Enviar avaliação', onPressed: _saveReview),
        ],
      ),
    );
  }
}

class _ScheduledReviewSummary extends StatelessWidget {
  final ScheduledService service;

  const _ScheduledReviewSummary({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(radius: 14),
      child: Row(
        children: [
          Avatar(provider: service.provider, size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.service.name,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                    '${service.provider.name} • ${service.date} às ${service.hour}',
                    style: const TextStyle(color: BColors.gray)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

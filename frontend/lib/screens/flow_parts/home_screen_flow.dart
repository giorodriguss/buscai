part of '../figma_flow.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final AppUser user;
  final VoidCallback onSearch;

  const HomeScreen({super.key, required this.user, required this.onSearch});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with AsyncLoadMixin {
  String selectedCategory = 'Todos';
  String? selectedFilter;
  String query = '';
  List<Provider> _apiProviders = [];
  bool _loadingProviders = false;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() => runAsync(
        call: ProvidersRepository.getAll,
        onSuccess: (data) => _apiProviders = data,
        setLoadingTrue: () => _loadingProviders = true,
        setLoadingFalse: () => _loadingProviders = false,
      );

  List<Provider> get filteredProviders => ProviderFilter.apply(
        base: _apiProviders.isNotEmpty ? _apiProviders : mockProviders,
        query: query,
        selectedCategory: selectedCategory,
        selectedFilter: selectedFilter,
      );

  @override
  Widget build(BuildContext context) {
    const categories = [
      'Todos',
      'Encanador',
      'Eletricista',
      'Pintor',
      'Manicure',
      'Mecânico',
      'Cabeleireira',
      'Marceneiro',
      'Diarista',
    ];
    const filters = ['Disponível agora', 'Mais avaliados', 'Mais próximos'];
    final topRatedProviders = [...mockProviders]..sort((a, b) => b.rating.compareTo(a.rating));
    final session = ref.watch(sessionProvider);
    final address = session.savedAddresses[session.selectedAddress];
    final firstName = widget.user.name.trim().split(RegExp(r'\s+')).first;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 18, 20, 24),
          decoration: const BoxDecoration(
            color: BColors.green,
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 14,
                offset: Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddressSelectionScreen()),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: BColors.orange, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Endereço', style: TextStyle(color: Color(0xB3F7F4EF), fontSize: 12)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        address.subtitle.replaceAll('\n', ' - '),
                                        style: const TextStyle(color: Colors.white, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    ),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_none_rounded, color: Colors.white),
                        Positioned(
                          right: 1,
                          top: 1,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: BColors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Olá, $firstName', style: const TextStyle(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 4),
              const Text(
                'O que você precisa hoje?',
                style: TextStyle(color: Color(0xCCF7F4EF), fontSize: 14),
              ),
              const SizedBox(height: 16),
              SearchField(
                hint: 'Buscar serviços ou profissionais...',
                onChanged: (value) => setState(() => query = value),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ServiceCarousel(onCategory: widget.onSearch),
              const SizedBox(height: 26),
              const SectionTitle('Categorias', size: 16),
              const SizedBox(height: 12),
              HorizontalChips(
                values: categories,
                selected: selectedCategory,
                onTap: (value) => setState(() => selectedCategory = value),
              ),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Icon(Icons.tune_rounded, color: BColors.gray, size: 18),
                  SizedBox(width: 8),
                  SectionTitle('Filtros', size: 16),
                ],
              ),
              const SizedBox(height: 12),
              HorizontalChips(
                values: filters,
                selected: selectedFilter,
                onTap: (value) => setState(() {
                  selectedFilter = selectedFilter == value ? null : value;
                }),
              ),
              const SizedBox(height: 24),
              const SectionTitle('Perto de você', size: 18),
              const SizedBox(height: 14),
              if (_loadingProviders)
                const AppLoadingIndicator()
              else
                ...filteredProviders.take(4).map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProviderCard(provider: p),
                  ),
                ),
              const SizedBox(height: 16),
              const SectionTitle('Mais avaliados do bairro', size: 18),
              const SizedBox(height: 14),
              SizedBox(
                height: 178,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) => ProviderCard(
                    provider: topRatedProviders[index],
                    compact: true,
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: 5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

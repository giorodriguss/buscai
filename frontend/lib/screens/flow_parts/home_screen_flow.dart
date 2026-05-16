part of '../figma_flow.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final AppUser user;
  final VoidCallback onSearch;

  const HomeScreen({super.key, required this.user, required this.onSearch});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AsyncLoadMixin<HomeScreen> {
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
    final session = ref.watch(sessionProvider);
    // Futuro backend: providers visiveis devem vir de GET /providers filtrando
    // perfil_publico=true. O provider local abaixo e so para preview offline.
    final localProvider =
        localCollaboratorProvider(session, ref.watch(collaboratorProvider));
    final baseProviders = [
      ...(_apiProviders.isNotEmpty ? _apiProviders : mockProviders),
      if (localProvider != null) localProvider,
    ];
    final filteredProviders = ProviderFilter.apply(
      base: baseProviders,
      query: query,
      selectedCategory: selectedCategory,
      selectedFilter: selectedFilter,
    );
    final topRatedProviders = [...baseProviders]
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final address = session.savedAddresses.isEmpty
        ? null
        : session.savedAddresses[session.selectedAddress
            .clamp(0, session.savedAddresses.length - 1)];
    final hasFavorites = session.favoriteProviderIds.isNotEmpty;
    final firstName = widget.user.name.trim().split(RegExp(r'\s+')).first;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
              20, MediaQuery.of(context).padding.top + 18, 20, 24),
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
                        MaterialPageRoute(
                            builder: (_) => const AddressSelectionScreen()),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: BColors.orange, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Endereço',
                                    style: TextStyle(
                                        color: Color(0xB3F7F4EF),
                                        fontSize: 12)),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        address == null
                                            ? 'Adicionar endereço'
                                            : address.subtitle
                                                .replaceAll('\n', ' - '),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: Colors.white,
                                        size: 18),
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
                    tooltip: 'Favoritos',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const FavoritesScreen()),
                    ),
                    icon: Icon(
                      hasFavorites
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: BColors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text('Olá, $firstName',
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
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

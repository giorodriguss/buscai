part of '../figma_flow.dart';

<<<<<<< HEAD
class HomeScreen extends ConsumerStatefulWidget {
=======
class HomeScreen extends StatefulWidget {
>>>>>>> origin/develop
  final AppUser user;
  final VoidCallback onSearch;

  const HomeScreen({super.key, required this.user, required this.onSearch});

  @override
<<<<<<< HEAD
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with AsyncLoadMixin {
=======
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
>>>>>>> origin/develop
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

<<<<<<< HEAD
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
=======
  Future<void> _loadProviders() async {
    setState(() => _loadingProviders = true);
    try {
      final data = await ProvidersApiService.instance.findAll();
      if (mounted) {
        setState(() => _apiProviders = data.map(Provider.fromApi).toList());
      }
    } catch (_) {
      // fallback to mock on error — no-op, filteredProviders already falls back
    } finally {
      if (mounted) setState(() => _loadingProviders = false);
    }
  }

  List<Provider> get filteredProviders {
    var providers = _apiProviders.isNotEmpty ? [..._apiProviders] : [...mockProviders];
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      providers = providers
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q) ||
              p.about.toLowerCase().contains(q))
          .toList();
    }
    if (selectedCategory != 'Todos') {
      providers = providers.where((p) => p.category == selectedCategory).toList();
    }
    if (selectedFilter == 'Mais avaliados') {
      providers.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (selectedFilter == 'Mais próximos') {
      providers.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (selectedFilter == 'Disponível agora') {
      providers = providers.where((p) => p.availableHours.isNotEmpty).toList();
    }
    return providers;
  }
>>>>>>> origin/develop

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
<<<<<<< HEAD
    final session = ref.watch(sessionProvider);
    final address = session.savedAddresses[session.selectedAddress];
=======
    final address = AppSession.savedAddresses[AppSession.selectedAddress];
>>>>>>> origin/develop
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
<<<<<<< HEAD
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddressSelectionScreen()),
                      ),
=======
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AddressSelectionScreen()),
                        );
                        if (mounted) setState(() {});
                      },
>>>>>>> origin/develop
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
<<<<<<< HEAD
                const AppLoadingIndicator()
=======
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(color: BColors.green),
                ))
>>>>>>> origin/develop
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
<<<<<<< HEAD
=======

// Busca e filtros locais. Futuro backend: enviar query/categoria/bairro para API
// e renderizar a resposta paginada.
>>>>>>> origin/develop

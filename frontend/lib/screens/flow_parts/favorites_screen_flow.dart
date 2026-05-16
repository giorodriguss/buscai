part of '../figma_flow.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with AsyncLoadMixin<FavoritesScreen> {
  List<Provider> _favorites = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() => runAsync(
        call: FavoritesRepository.getMine,
        onSuccess: (data) => _favorites = data,
        setLoadingTrue: () => _loading = true,
        setLoadingFalse: () => _loading = false,
      );

  @override
  Widget build(BuildContext context) {
    final favoriteIds = ref.watch(sessionProvider).favoriteProviderIds;
    final localFavorites = mockProviders
        .where((provider) => favoriteIds.contains(provider.id))
        .toList();
    final providers = localFavorites.isNotEmpty ? localFavorites : _favorites;

    return SimplePage(
      title: 'Favoritos',
      bottomPadding: true,
      child: _loading && providers.isEmpty
          ? const AppLoadingIndicator(verticalPadding: 48)
          : providers.isEmpty
              ? const EmptyPanel(
                  icon: Icons.favorite_border_rounded,
                  text: 'Seus prestadores favoritos aparecerão aqui.',
                )
              : Column(
                  children: providers
                      .map(
                        (provider) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProviderCard(provider: provider),
                        ),
                      )
                      .toList(),
                ),
    );
  }
}

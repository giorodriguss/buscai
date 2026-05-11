part of '../figma_flow.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with AsyncLoadMixin {
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
    return SimplePage(
      title: 'Favoritos',
      bottomPadding: true,
      child: _loading
          ? const AppLoadingIndicator(verticalPadding: 48)
          : _favorites.isEmpty
              ? const EmptyPanel(
                  icon: Icons.favorite_border_rounded,
                  text: 'Seus prestadores favoritos aparecerão aqui.',
                )
              : Column(
                  children: _favorites
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

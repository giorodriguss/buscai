part of '../figma_flow.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Provider> _favorites = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    try {
      final data = await FavoritesApiService.instance.findMine();
      if (mounted) {
        final providers = data
            .map((item) {
              final post = item['posts'] as Map<String, dynamic>?;
              if (post == null) return null;
              return Provider.fromApi(post);
            })
            .whereType<Provider>()
            .toList();
        setState(() => _favorites = providers);
      }
    } catch (_) {
      // silently fall through to empty state
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimplePage(
      title: 'Favoritos',
      bottomPadding: true,
      child: _loading
          ? const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(color: BColors.green),
            ))
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

// Lista de categorias usada no cadastro de prestador. Deve virar dados do
// backend para manter categorias padronizadas.

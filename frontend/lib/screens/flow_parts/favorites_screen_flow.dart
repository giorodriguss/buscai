part of '../figma_flow.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteProviders = mockProviders
        .where((provider) => AppSession.favoriteProviderIds.contains(provider.id))
        .toList();
    return SimplePage(
      title: 'Favoritos',
      child: favoriteProviders.isEmpty
          ? const EmptyPanel(
              icon: Icons.favorite_border_rounded,
              text: 'Seus prestadores favoritos aparecerão aqui.',
            )
          : Column(
              children: favoriteProviders
                  .map(
                    (provider) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProviderCard(provider: provider),
                    ),
                  )
                  .toList(),
            ),
      bottomPadding: true,
    );
  }
}

// Lista de categorias usada no cadastro de prestador. Deve virar dados do
// backend para manter categorias padronizadas.

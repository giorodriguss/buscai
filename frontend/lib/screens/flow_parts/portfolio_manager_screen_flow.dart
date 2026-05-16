part of '../figma_flow.dart';

class PortfolioManagerScreen extends ConsumerStatefulWidget {
  const PortfolioManagerScreen({super.key});

  @override
  ConsumerState<PortfolioManagerScreen> createState() =>
      _PortfolioManagerScreenState();
}

class _PortfolioManagerScreenState
    extends ConsumerState<PortfolioManagerScreen> {
  Future<void> _addPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final mime = picked.mimeType ?? 'image/jpeg';
    final dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
    // Futuro backend: enviar bytes para Storage e salvar a URL em post_photos.
    // Hoje guardamos data URL localmente para o protótipo funcionar offline.
    ref.read(collaboratorProvider.notifier).addPortfolioPhoto(dataUrl);
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = ref.watch(collaboratorProvider).portfolio;
    return Scaffold(
      backgroundColor: BColors.paper,
      appBar: const _GreenAppBar(title: 'Gerenciar Portfólio'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PrimaryButton(
            label: 'Adicionar foto',
            icon: Icons.add_rounded,
            color: BColors.green,
            onPressed: _addPhoto,
          ),
          const SizedBox(height: 18),
          if (portfolio.isEmpty)
            const EmptyPanel(
              icon: Icons.photo_library_outlined,
              text: 'Escolha imagens do dispositivo para montar seu portfólio.',
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: portfolio.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (_, index) => Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image(
                        image: _imageProviderFromValue(portfolio[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => ref
                          .read(collaboratorProvider.notifier)
                          .removePortfolioPhoto(index),
                      child: const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.redAccent,
                        child: Icon(Icons.close_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

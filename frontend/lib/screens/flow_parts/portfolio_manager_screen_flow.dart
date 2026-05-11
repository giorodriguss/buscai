part of '../figma_flow.dart';

class PortfolioManagerScreen extends ConsumerWidget {
  const PortfolioManagerScreen({super.key});

  static const _extraPhoto = 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=500';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onPressed: () => ref.read(collaboratorProvider.notifier).addPortfolioPhoto(_extraPhoto),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: portfolio.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemBuilder: (_, index) => Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(portfolio[index], fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => ref.read(collaboratorProvider.notifier).removePortfolioPhoto(index),
                    child: const CircleAvatar(radius: 16, backgroundColor: Colors.redAccent, child: Icon(Icons.close_rounded, color: Colors.white, size: 18)),
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

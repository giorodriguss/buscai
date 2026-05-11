part of '../figma_flow.dart';

<<<<<<< HEAD
class PortfolioManagerScreen extends ConsumerWidget {
  const PortfolioManagerScreen({super.key});

  static const _extraPhoto = 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=500';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(collaboratorProvider).portfolio;
=======
class PortfolioManagerScreen extends StatefulWidget {
  const PortfolioManagerScreen({super.key});

  @override
  State<PortfolioManagerScreen> createState() => _PortfolioManagerScreenState();
}

class _PortfolioManagerScreenState extends State<PortfolioManagerScreen> {
  static const extraPhoto = 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=500';

  @override
  Widget build(BuildContext context) {
>>>>>>> origin/develop
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
<<<<<<< HEAD
            onPressed: () => ref.read(collaboratorProvider.notifier).addPortfolioPhoto(_extraPhoto),
=======
            onPressed: () => setState(() {
              CollaboratorState.portfolio.insert(0, extraPhoto);
            }),
>>>>>>> origin/develop
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
<<<<<<< HEAD
            itemCount: portfolio.length,
=======
            itemCount: CollaboratorState.portfolio.length,
>>>>>>> origin/develop
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemBuilder: (_, index) => Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
<<<<<<< HEAD
                    child: Image.network(portfolio[index], fit: BoxFit.cover),
=======
                    child: Image.network(CollaboratorState.portfolio[index], fit: BoxFit.cover),
>>>>>>> origin/develop
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
<<<<<<< HEAD
                    onTap: () => ref.read(collaboratorProvider.notifier).removePortfolioPhoto(index),
=======
                    onTap: () => setState(() => CollaboratorState.portfolio.removeAt(index)),
>>>>>>> origin/develop
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

part of '../figma_flow.dart';

class PortfolioManagerScreen extends StatefulWidget {
  const PortfolioManagerScreen({super.key});

  @override
  State<PortfolioManagerScreen> createState() => _PortfolioManagerScreenState();
}

class _PortfolioManagerScreenState extends State<PortfolioManagerScreen> {
  static const extraPhoto = 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=500';

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => setState(() {
              CollaboratorState.portfolio.insert(0, extraPhoto);
            }),
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: CollaboratorState.portfolio.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemBuilder: (_, index) => Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(CollaboratorState.portfolio[index], fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => CollaboratorState.portfolio.removeAt(index)),
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

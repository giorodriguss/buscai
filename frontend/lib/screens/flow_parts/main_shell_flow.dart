part of '../figma_flow.dart';

class MainShell extends StatefulWidget {
  final AppUser user;

  const MainShell({super.key, required this.user});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(user: widget.user, onSearch: () => setState(() => _index = 1)),
      const SearchScreen(),
      const FavoritesScreen(),
      ProfileScreen(user: widget.user),
      if (widget.user.isProvider) CollaboratorScreen(user: widget.user),
    ];
    return Scaffold(
      backgroundColor: BColors.paper,
      body: Stack(
        children: [
          Positioned.fill(child: pages[_index]),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNav(
              index: _index,
              showCollaborator: widget.user.isProvider,
              onChanged: (i) => setState(() => _index = i),
            ),
          ),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
// Feed inicial do usuario comum. Endereco vem do sessionProvider e lista
=======
// Feed inicial do usuario comum. Usa nome/endereco da AppSession e lista
>>>>>>> origin/develop
// prestadores mockados ate existir endpoint de feed.

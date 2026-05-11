part of '../figma_flow.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  String? selectedCategory;
  final searchController = TextEditingController();

  final categories = const [
    ('Manutenção', Icons.build_rounded, BColors.green),
    ('Estética', Icons.content_cut_rounded, BColors.orange),
    ('Automotivo', Icons.directions_car_rounded, BColors.green),
    ('Limpeza', Icons.auto_awesome_rounded, BColors.orange),
    ('Casa', Icons.home_rounded, BColors.green),
    ('Tecnologia', Icons.laptop_mac_rounded, BColors.orange),
    ('Arte', Icons.brush_rounded, BColors.green),
    ('Fotografia', Icons.camera_alt_rounded, BColors.orange),
    ('Eventos', Icons.music_note_rounded, BColors.green),
    ('Alimentação', Icons.coffee_rounded, BColors.orange),
    ('Fitness', Icons.fitness_center_rounded, BColors.green),
    ('Educação', Icons.school_rounded, BColors.orange),
  ];

<<<<<<< HEAD
=======
  List<String> mapCategory(String category) {
    return switch (category) {
      'Manutenção' => ['Encanador', 'Eletricista', 'Pintor', 'Marceneiro'],
      'Estética' => ['Manicure', 'Cabeleireira'],
      'Automotivo' => ['Mecânico'],
      'Limpeza' => ['Diarista'],
      'Casa' => ['Encanador', 'Eletricista', 'Pintor', 'Marceneiro'],
      _ => [],
    };
  }

>>>>>>> origin/develop
  List<Provider> get results {
    var providers = [...mockProviders];
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      providers = providers
          .where((p) => p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q))
          .toList();
    }
    if (selectedCategory != null) {
<<<<<<< HEAD
      final allowed = ProviderFilter.categoriesFor(selectedCategory!);
=======
      final allowed = mapCategory(selectedCategory!);
>>>>>>> origin/develop
      providers = providers.where((p) => allowed.contains(p.category)).toList();
    }
    return providers;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showingResults = selectedCategory != null || query.isNotEmpty;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 16),
          color: BColors.green,
          child: Row(
            children: [
              if (showingResults)
                IconButton(
                  onPressed: () => setState(() {
                    selectedCategory = null;
                    query = '';
                    searchController.clear();
                  }),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
              Expanded(
                child: SearchField(
                  hint: showingResults ? 'Buscar serviços...' : 'Que serviço você precisa?',
                  controller: searchController,
                  onChanged: (value) => setState(() => query = value),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: showingResults
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
                  children: results.isEmpty
                      ? const [EmptySearch()]
                      : results
                          .map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ProviderCard(provider: p),
                              ))
                          .toList(),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.65,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (_, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = category.$1),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: BColors.border, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: category.$3.withValues(alpha: .08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(category.$2, color: category.$3, size: 23),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              category.$1,
                              style: const TextStyle(
                                color: BColors.black,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
<<<<<<< HEAD
=======

// Detalhe do prestador visto pelo usuario. Aqui ficam favorito, escolha de
// servico, data/horario e criacao do historico local de agendamento.
>>>>>>> origin/develop

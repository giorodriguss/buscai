part of '../figma_flow.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  static final categories = [
    // Futuro backend: categorias devem vir de uma tabela/endpoint administrável.
    // Hoje deixamos local para o protótipo continuar navegável sem API.
    'Encanador',
    'Eletricista',
    'Pintor',
    'Marceneiro',
    'Pedreiro',
    'Serralheiro',
    'Vidraceiro',
    'Gesseiro',
    'Azulejista',
    'Marmorista',
    'Manicure',
    'Pedicure',
    'Cabeleireiro',
    'Barbeiro',
    'Maquiador',
    'Designer de Sobrancelhas',
    'Esteticista',
    'Massagista',
    'Personal Trainer',
    'Mecânico',
    'Funileiro',
    'Eletricista Automotivo',
    'Borracheiro',
    'Jardineiro',
    'Paisagista',
    'Diarista',
    'Faxineira',
    'Passadeira',
    'Cozinheira',
    'Personal Chef',
    'Confeiteira',
    'Salgadeira',
    'DJ',
    'Fotógrafo',
    'Cinegrafista',
    'Decorador',
    'Buffet',
    'Técnico de Informática',
    'Técnico de Celular',
    'Instalador de Ar Condicionado',
    'Técnico de TV',
    'Costureira',
    'Alfaiate',
    'Sapateiro',
    'Chaveiro',
    'Dedetizador',
    'Limpeza de Piscina',
    'Motorista Particular',
    'Mudanças',
    'Professor Particular',
    'Advogado',
    'Contador',
    'Arquiteto',
    'Designer Gráfico',
    'Redator',
    'Tradutor',
  ]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColors.paper,
      appBar: const _GreenAppBar(
        title: 'Selecione sua categoria',
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(58),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: SearchField(hint: 'Buscar categoria...'),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 3.25,
        ),
        itemBuilder: (_, index) => GestureDetector(
          onTap: () => Navigator.of(context).pop(categories[index]),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: BColors.border, width: 2),
            ),
            child: Text(categories[index],
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

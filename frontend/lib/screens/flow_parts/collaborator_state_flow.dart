part of '../figma_flow.dart';

class ProviderServiceDraft {
  String name;
  String price;
  String duration;

  ProviderServiceDraft({required this.name, required this.price, required this.duration});
}

// Estado local da area Colaborador. Tudo aqui e editavel no front e deve ser
// substituido por endpoints de perfil, servicos, disponibilidade e portfolio.
class CollaboratorState {
  // Perfil profissional em memória. Backend deve substituir por endpoints de:
  // perfil do colaborador, serviços, disponibilidade, portfólio e avaliações.
  static String category = 'ENCANADOR';
  static int years = 10;
  static String coverImage = 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=900';
  static Color profileColor = BColors.green;
  static String about =
      'Profissional com mais de 10 anos de experiência em manutenção hidráulica residencial e comercial.';
  static final services = <ProviderServiceDraft>[
    ProviderServiceDraft(name: 'Desentupimento de pia', price: '80', duration: '1h'),
    ProviderServiceDraft(name: 'Reparo de vazamento', price: '100', duration: '1-2h'),
    ProviderServiceDraft(name: 'Instalação de torneira', price: '90', duration: '45min'),
  ];
  static final days = <String>{'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'};
  static final hours = <String>{'08:00', '09:00', '10:00', '14:00', '15:00', '16:00', '17:00'};
  static final portfolio = <String>[
    'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=500',
    'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=500',
    'https://images.unsplash.com/photo-1581092583537-20d51b4b4f1b?w=500',
    'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500',
  ];

  static void resetForNewProvider(String selectedCategory) {
    // Cadastro novo comeca limpo: a pessoa vai preencher tudo no painel
    // Colaborador. Quando o backend entrar, esse reset vira o payload inicial.
    category = selectedCategory.toUpperCase();
    years = 0;
    coverImage = 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=900';
    profileColor = BColors.green;
    about = '';
    services.clear();
    days.clear();
    hours.clear();
    portfolio.clear();
  }
}

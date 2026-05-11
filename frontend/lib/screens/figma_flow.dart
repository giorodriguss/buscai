import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'flow_parts/splash_screen_flow.dart';
part 'flow_parts/onboarding_screen_flow.dart';
part 'flow_parts/login_screen_flow.dart';
part 'flow_parts/login_provider_screen_flow.dart';
part 'flow_parts/signup_screen_flow.dart';
part 'flow_parts/signup_provider_screen_flow.dart';
part 'flow_parts/main_shell_flow.dart';
part 'flow_parts/home_screen_flow.dart';
part 'flow_parts/search_screen_flow.dart';
part 'flow_parts/provider_profile_screen_flow.dart';
part 'flow_parts/profile_screen_flow.dart';
part 'flow_parts/collaborator_state_flow.dart';
part 'flow_parts/collaborator_screen_flow.dart';
part 'flow_parts/edit_provider_profile_screen_flow.dart';
part 'flow_parts/availability_screens_flow.dart';
part 'flow_parts/portfolio_manager_screen_flow.dart';
part 'flow_parts/favorites_screen_flow.dart';
part 'flow_parts/category_selection_screen_flow.dart';
part 'flow_parts/address_screens_flow.dart';
part 'flow_parts/shared_widgets_flow.dart';

// Arquivo central do prototipo Buscaí.
//
// IMPORTANTE PARA QUEM CONTINUAR:
// - Esse fluxo ainda e 100% frontend, sem banco/API.
// - Os dados que "persistem" vivem em memoria nas classes AppSession e
//   CollaboratorState. Ao recarregar o app, tudo volta ao estado inicial.
// - Os comentarios marcados como "Futuro backend" mostram os pontos naturais
//   para trocar mock/local state por chamadas reais da API.
// - A fonte Georgia e aplicada nos widgets deste arquivo para manter o visual
//   mais proximo do Figma.

// Tokens visuais do app. Mantemos as cores centralizadas para evitar tons
// diferentes de verde/laranja espalhados pela interface.
class BColors {
  static const green = Color(0xFF1A3A2A);
  static const greenDark = Color(0xFF0F2519);
  static const orange = Color(0xFFE85C2A);
  static const black = Color(0xFF0F0E0D);
  static const paper = Color(0xFFF7F4EF);
  static const gray = Color(0xFF7A7570);
  static const border = Color(0xFFDDD9D2);
  static const whatsapp = Color(0xFF25D366);
}

class Service {
  final String id;
  final String name;
  final int price;

  const Service({required this.id, required this.name, required this.price});
}

// Modelo simples de avaliacao usado nos perfis mockados de prestadores.
class Review {
  final String name;
  final int rating;
  final String comment;
  final String date;

  const Review({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
  });
}

// Usuario logado no front. O campo isProvider controla se aparece a aba
// Colaborador no menu inferior.
class AppUser {
  String name;
  String email;
  String phone;
  bool isProvider;

  AppUser({
    required this.name,
    required this.email,
    this.phone = '',
    this.isProvider = false,
  });
}

// Item do historico local criado quando a pessoa agenda um servico.
class ServiceHistoryItem {
  final Provider provider;
  final Service service;
  final String date;

  const ServiceHistoryItem({
    required this.provider,
    required this.service,
    required this.date,
  });
}

// Fonte de verdade temporaria para a visao de usuario.
// Futuro backend: substituir por AuthProvider/Repository com dados vindos da API.
class AppSession {
  // Estado temporário do front. Quando existir backend, isso deve sair daqui e vir
  // de autenticação/API (usuário logado, favoritos, histórico e endereços).
  static AppUser? currentUser;
  static int selectedAddress = 0;
  static final favoriteProviderIds = <String>{};
  static final history = <ServiceHistoryItem>[];
  static final savedAddresses = <_SavedAddress>[..._defaultAddresses()];

  static List<_SavedAddress> _defaultAddresses() => const [
        _SavedAddress(
          type: 'Casa',
          title: 'Casa',
          subtitle: 'Rua das Flores, 123 - Vila Madalena,\nSão Paulo',
          icon: Icons.home_outlined,
        ),
        _SavedAddress(
          type: 'Trabalho',
          title: 'Trabalho',
          subtitle: 'Av. Paulista, 1000 - Bela Vista, São\nPaulo',
          icon: Icons.work_outline_rounded,
        ),
      ];

  static void reset() {
    currentUser = null;
    favoriteProviderIds.clear();
    history.clear();
    savedAddresses
      ..clear()
      ..addAll(_defaultAddresses());
    selectedAddress = 0;
  }
}

// Validacoes iguais para cadastro comum e cadastro de prestador.
// Hoje exigimos email terminando em .com porque foi a regra pedida no prototipo.
bool _isValidEmail(String value) {
  return RegExp(r'^[^\s@]+@[^\s@]+\.[cC][oO][mM]$').hasMatch(value.trim());
}

// Telefone deve ficar no formato "00 90000-0000". O usuario digita so numeros
// e o PhoneInputFormatter faz a mascara automaticamente.
bool _isValidPhone(String value) {
  return RegExp(r'^\d{2} 9\d{4}-\d{4}$').hasMatch(value.trim());
}

// Lista base de horarios usada no cadastro/edicao de disponibilidade.
// Futuro backend: esses horarios podem vir parametrizados por categoria/cidade.
const serviceHours = [
  '04:00',
  '05:00',
  '06:00',
  '07:00',
  '08:00',
  '09:00',
  '10:00',
  '11:00',
  '12:00',
  '13:00',
  '14:00',
  '15:00',
  '16:00',
  '17:00',
  '18:00',
  '19:00',
  '20:00',
  '21:00',
  '22:00',
  '23:00',
  '00:00',
];

class PhoneInputFormatter extends TextInputFormatter {
  const PhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // O usuário digita só números; o campo mostra automaticamente 00 90000-0000.
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      if (i == 2) buffer.write(' ');
      if (i == 7) buffer.write('-');
      buffer.write(limited[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Prestador exibido na home, busca e detalhe. Por enquanto os objetos abaixo
// sao mockados; no backend isso deve virar DTO/modelo recebido da API.
class Provider {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final String distance;
  final String image;
  final String coverImage;
  final String about;
  final String phone;
  final List<String> portfolio;
  final List<Review> reviews;
  final List<String> availableHours;
  final int pricePerHour;
  final String priceRange;
  final int yearsExperience;
  final List<Service> services;

  const Provider({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.image,
    required this.coverImage,
    required this.about,
    required this.phone,
    required this.portfolio,
    required this.reviews,
    required this.availableHours,
    required this.pricePerHour,
    required this.priceRange,
    required this.yearsExperience,
    required this.services,
  });
}

// Catalogo mockado usado por Home, Busca e Detalhe. A estrutura ja esta perto
// do que o backend deve devolver: lista de prestadores com servicos e horarios.
const mockProviders = [
  // Mock local para demonstrar o feed. No backend, esses providers devem vir
  // paginados da API, já filtrados por bairro/categoria/avaliação quando possível.
  Provider(
    id: '1',
    name: 'João Silva',
    category: 'Encanador',
    rating: 4.8,
    reviewCount: 127,
    distance: '0.5 km',
    image: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=300&h=300&fit=crop',
    coverImage: 'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=800',
    about:
        'Profissional com mais de 10 anos de experiência em manutenção hidráulica residencial e comercial. Atendimento rápido e garantia em todos os serviços.',
    phone: '5511999999999',
    pricePerHour: 85,
    priceRange: 'R\$ 80-150',
    yearsExperience: 10,
    services: [
      Service(id: '1', name: 'Desentupimento de pia', price: 80),
      Service(id: '2', name: 'Reparo de vazamento', price: 100),
      Service(id: '3', name: 'Instalação de torneira', price: 90),
      Service(id: '4', name: 'Troca de sifão', price: 70),
      Service(id: '5', name: 'Reparo de descarga', price: 85),
    ],
    portfolio: [
      'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=400',
      'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=400',
      'https://images.unsplash.com/photo-1581092583537-20d51b4b4f1b?w=400',
      'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=400',
    ],
    availableHours: ['14:00', '15:00', '16:00', '17:00'],
    reviews: [
      Review(
        name: 'Maria Souza',
        rating: 5,
        comment: 'Excelente profissional! Resolveu o problema rapidamente.',
        date: '2 dias atrás',
      ),
      Review(
        name: 'Carlos Lima',
        rating: 5,
        comment: 'Muito atencioso e caprichoso. Recomendo!',
        date: '1 semana atrás',
      ),
    ],
  ),
  Provider(
    id: '2',
    name: 'Maria Santos',
    category: 'Eletricista',
    rating: 4.9,
    reviewCount: 89,
    distance: '1.2 km',
    pricePerHour: 95,
    priceRange: 'R\$ 90-180',
    yearsExperience: 6,
    image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300&h=300&fit=crop',
    coverImage: 'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=800',
    about:
        'Eletricista certificada, especialista em instalações elétricas e manutenção preventiva. Trabalho com segurança e qualidade.',
    phone: '5511988888888',
    services: [
      Service(id: '1', name: 'Instalação de lustre', price: 90),
      Service(id: '2', name: 'Troca de tomadas', price: 70),
      Service(id: '3', name: 'Instalação de chuveiro', price: 120),
      Service(id: '4', name: 'Reparo de disjuntor', price: 100),
    ],
    portfolio: [
      'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=400',
      'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=400',
    ],
    availableHours: ['09:00', '10:00', '14:00', '15:00'],
    reviews: [
      Review(
        name: 'Pedro Costa',
        rating: 5,
        comment: 'Profissional excelente, muito técnica e cuidadosa.',
        date: '3 dias atrás',
      ),
    ],
  ),
  Provider(
    id: '3',
    name: 'Pedro Costa',
    category: 'Pintor',
    rating: 4.7,
    reviewCount: 156,
    distance: '0.8 km',
    pricePerHour: 120,
    priceRange: 'R\$ 200-800',
    yearsExperience: 15,
    image: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=300&h=300&fit=crop',
    coverImage: 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=800',
    about:
        '15 anos de experiência em pintura residencial e comercial. Acabamento perfeito garantido.',
    phone: '5511977777777',
    services: [
      Service(id: '1', name: 'Pintura de quarto', price: 400),
      Service(id: '2', name: 'Pintura de sala', price: 500),
      Service(id: '3', name: 'Pintura de fachada', price: 800),
    ],
    portfolio: [
      'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=400',
      'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=400',
    ],
    availableHours: ['08:00', '09:00', '13:00', '14:00'],
    reviews: [
      Review(
        name: 'Roberto Lima',
        rating: 5,
        comment: 'Trabalho impecável! Pintou minha sala e ficou perfeito.',
        date: '1 semana atrás',
      ),
      Review(
        name: 'Mariana Silva',
        rating: 5,
        comment: 'Profissional muito cuidadoso e pontual.',
        date: '2 semanas atrás',
      ),
    ],
  ),
  Provider(
    id: '4',
    name: 'Ana Oliveira',
    category: 'Manicure',
    rating: 5.0,
    reviewCount: 203,
    distance: '0.3 km',
    pricePerHour: 60,
    priceRange: 'R\$ 50-100',
    yearsExperience: 8,
    image: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&h=300&fit=crop',
    coverImage: 'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=800',
    about:
        'Manicure e pedicure profissional. Atendo em domicílio com todos os cuidados de higiene.',
    phone: '5511966666666',
    services: [
      Service(id: '1', name: 'Manicure simples', price: 40),
      Service(id: '2', name: 'Pedicure simples', price: 45),
      Service(id: '3', name: 'Manicure + Pedicure', price: 75),
      Service(id: '4', name: 'Unhas decoradas', price: 60),
    ],
    portfolio: [
      'https://images.unsplash.com/photo-1604654894610-df63bc536371?w=400',
      'https://images.unsplash.com/photo-1610992015732-2449b76344bc?w=400',
    ],
    availableHours: ['10:00', '11:00', '14:00', '15:00', '16:00'],
    reviews: [
      Review(
        name: 'Julia Santos',
        rating: 5,
        comment: 'A melhor manicure que já conheci! Super caprichosa.',
        date: '1 dia atrás',
      ),
    ],
  ),
  Provider(
    id: '5',
    name: 'Carlos Mendes',
    category: 'Mecânico',
    rating: 4.6,
    reviewCount: 98,
    distance: '1.5 km',
    pricePerHour: 110,
    priceRange: 'R\$ 100-300',
    yearsExperience: 12,
    image: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=300&h=300&fit=crop',
    coverImage: 'https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=800',
    about:
        'Mecânico automotivo com oficina própria. Especialista em revisão e manutenção de veículos.',
    phone: '5511955555555',
    services: [
      Service(id: '1', name: 'Troca de óleo', price: 150),
      Service(id: '2', name: 'Alinhamento e balanceamento', price: 120),
      Service(id: '3', name: 'Troca de pastilha de freio', price: 200),
    ],
    portfolio: ['https://images.unsplash.com/photo-1486262715619-67b85e0b08d3?w=400'],
    availableHours: ['08:00', '09:00', '10:00', '13:00', '14:00'],
    reviews: [],
  ),
  Provider(
    id: '6',
    name: 'Fernanda Lima',
    category: 'Cabeleireira',
    rating: 4.9,
    reviewCount: 178,
    distance: '0.6 km',
    pricePerHour: 80,
    priceRange: 'R\$ 50-200',
    yearsExperience: 9,
    image: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300&h=300&fit=crop',
    coverImage: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=800',
    about:
        'Cabeleireira especializada em cortes modernos, coloração e tratamentos capilares.',
    phone: '5511944444444',
    services: [
      Service(id: '1', name: 'Corte feminino', price: 60),
      Service(id: '2', name: 'Corte masculino', price: 40),
      Service(id: '3', name: 'Escova', price: 50),
      Service(id: '4', name: 'Coloração', price: 150),
    ],
    portfolio: [
      'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=400',
      'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
    ],
    availableHours: ['09:00', '10:00', '11:00', '14:00', '15:00'],
    reviews: [],
  ),
  Provider(
    id: '7',
    name: 'Roberto Alves',
    category: 'Marceneiro',
    rating: 4.8,
    reviewCount: 67,
    distance: '2.1 km',
    pricePerHour: 100,
    priceRange: 'R\$ 150-1000',
    yearsExperience: 18,
    image: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=300&h=300&fit=crop',
    coverImage: 'https://images.unsplash.com/photo-1513828583688-c52646db42da?w=800',
    about:
        'Marceneiro especialista em móveis planejados e reformas. Trabalho com madeira de qualidade.',
    phone: '5511933333333',
    services: [
      Service(id: '1', name: 'Prateleira sob medida', price: 300),
      Service(id: '2', name: 'Armário planejado', price: 1500),
    ],
    portfolio: ['https://images.unsplash.com/photo-1513828583688-c52646db42da?w=400'],
    availableHours: ['08:00', '13:00', '14:00'],
    reviews: [],
  ),
  Provider(
    id: '8',
    name: 'Juliana Rocha',
    category: 'Diarista',
    rating: 4.7,
    reviewCount: 145,
    distance: '1.0 km',
    pricePerHour: 70,
    priceRange: 'R\$ 120-180',
    yearsExperience: 5,
    image: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&h=300&fit=crop',
    coverImage: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
    about:
        'Diarista profissional com experiência em limpeza residencial. Trabalho com produtos próprios.',
    phone: '5511922222222',
    services: [
      Service(id: '1', name: 'Limpeza básica (4h)', price: 140),
      Service(id: '2', name: 'Limpeza completa (8h)', price: 280),
    ],
    portfolio: [],
    availableHours: ['08:00', '09:00', '13:00'],
    reviews: [],
  ),
];

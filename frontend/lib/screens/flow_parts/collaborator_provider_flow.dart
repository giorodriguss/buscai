part of '../figma_flow.dart';

class CollaboratorData {
  final String category;
  final int years;
  final String coverImage;
  final Color profileColor;
  final String about;
  final List<ProviderServiceDraft> services;
  final Set<String> days;
  final Set<String> hours;
  final List<String> portfolio;

  const CollaboratorData({
    this.category = 'ENCANADOR',
    this.years = 10,
    this.coverImage =
        'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=900',
    this.profileColor = BColors.green,
    this.about =
        'Profissional com mais de 10 anos de experiência em manutenção hidráulica residencial e comercial.',
    this.services = const [],
    this.days = const {},
    this.hours = const {},
    this.portfolio = const [],
  });

  CollaboratorData copyWith({
    String? category,
    int? years,
    String? coverImage,
    Color? profileColor,
    String? about,
    List<ProviderServiceDraft>? services,
    Set<String>? days,
    Set<String>? hours,
    List<String>? portfolio,
  }) {
    return CollaboratorData(
      category: category ?? this.category,
      years: years ?? this.years,
      coverImage: coverImage ?? this.coverImage,
      profileColor: profileColor ?? this.profileColor,
      about: about ?? this.about,
      services: services ?? this.services,
      days: days ?? this.days,
      hours: hours ?? this.hours,
      portfolio: portfolio ?? this.portfolio,
    );
  }
}

class CollaboratorNotifier extends Notifier<CollaboratorData> {
  @override
  CollaboratorData build() => CollaboratorData(
        services: [
          ProviderServiceDraft(name: 'Desentupimento de pia', price: '80', duration: '1h'),
          ProviderServiceDraft(name: 'Reparo de vazamento', price: '100', duration: '1-2h'),
          ProviderServiceDraft(name: 'Instalação de torneira', price: '90', duration: '45min'),
        ],
        days: const {'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'},
        hours: const {'08:00', '09:00', '10:00', '14:00', '15:00', '16:00', '17:00'},
        portfolio: const [
          'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=500',
          'https://images.unsplash.com/photo-1607472586893-edb57bdc0e39?w=500',
          'https://images.unsplash.com/photo-1581092583537-20d51b4b4f1b?w=500',
          'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=500',
        ],
      );

  void setYears(int years) => state = state.copyWith(years: years);

  void setCoverImage(String url) => state = state.copyWith(coverImage: url);

  void setProfileColor(Color color) => state = state.copyWith(profileColor: color);

  void setAbout(String about) => state = state.copyWith(about: about);

  void addService(ProviderServiceDraft service) =>
      state = state.copyWith(services: [service, ...state.services]);

  void editService(int index, ProviderServiceDraft service) {
    final services = [...state.services];
    services[index] = service;
    state = state.copyWith(services: services);
  }

  void removeService(int index) {
    final services = [...state.services];
    services.removeAt(index);
    state = state.copyWith(services: services);
  }

  void setDays(Set<String> days) => state = state.copyWith(days: days);

  void setHours(Set<String> hours) => state = state.copyWith(hours: hours);

  void addPortfolioPhoto(String url) =>
      state = state.copyWith(portfolio: [url, ...state.portfolio]);

  void removePortfolioPhoto(int index) {
    final portfolio = [...state.portfolio];
    portfolio.removeAt(index);
    state = state.copyWith(portfolio: portfolio);
  }

  void reset(String selectedCategory) => state = CollaboratorData(
        category: selectedCategory.toUpperCase(),
        years: 0,
        about: '',
        services: const [],
        days: const {},
        hours: const {},
        portfolio: const [],
      );
}

final collaboratorProvider =
    NotifierProvider<CollaboratorNotifier, CollaboratorData>(
  CollaboratorNotifier.new,
);

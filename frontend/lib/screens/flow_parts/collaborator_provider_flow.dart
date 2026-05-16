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
    this.category = '',
    this.years = 0,
    this.coverImage = '',
    this.profileColor = BColors.green,
    this.about = '',
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
  // Estado local temporario do perfil do colaborador. Futuro backend: carregar
  // de providers/posts/services/availability/portfolio pelo usuario logado.
  CollaboratorData build() => const CollaboratorData();

  void setCategory(String category) =>
      state = state.copyWith(category: category.toUpperCase());

  void setYears(int years) => state = state.copyWith(years: years);

  void setCoverImage(String url) => state = state.copyWith(coverImage: url);

  void setProfileColor(Color color) =>
      state = state.copyWith(profileColor: color);

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
      );
}

final collaboratorProvider =
    NotifierProvider<CollaboratorNotifier, CollaboratorData>(
  CollaboratorNotifier.new,
);

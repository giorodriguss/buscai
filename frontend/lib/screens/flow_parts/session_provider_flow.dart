part of '../figma_flow.dart';

class SessionState {
  final AppUser? currentUser;
  final int selectedAddress;
  final Set<String> favoriteProviderIds;
  final List<ServiceHistoryItem> history;
  final List<UserServiceReview> userReviews;
  final List<_SavedAddress> savedAddresses;
  final bool notificationsEnabled;
  final bool serviceAlertsEnabled;
  final bool profileVisible;
  final bool dataSharingEnabled;

  const SessionState({
    this.currentUser,
    this.selectedAddress = 0,
    this.favoriteProviderIds = const {},
    this.history = const [],
    this.userReviews = const [],
    this.notificationsEnabled = true,
    this.serviceAlertsEnabled = true,
    this.profileVisible = true,
    this.dataSharingEnabled = false,
    required this.savedAddresses,
  });

  SessionState copyWith({
    AppUser? currentUser,
    int? selectedAddress,
    Set<String>? favoriteProviderIds,
    List<ServiceHistoryItem>? history,
    List<UserServiceReview>? userReviews,
    List<_SavedAddress>? savedAddresses,
    bool? notificationsEnabled,
    bool? serviceAlertsEnabled,
    bool? profileVisible,
    bool? dataSharingEnabled,
  }) {
    return SessionState(
      currentUser: currentUser ?? this.currentUser,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      favoriteProviderIds: favoriteProviderIds ?? this.favoriteProviderIds,
      history: history ?? this.history,
      userReviews: userReviews ?? this.userReviews,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      serviceAlertsEnabled: serviceAlertsEnabled ?? this.serviceAlertsEnabled,
      profileVisible: profileVisible ?? this.profileVisible,
      dataSharingEnabled: dataSharingEnabled ?? this.dataSharingEnabled,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
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

  @override
  SessionState build() => SessionState(savedAddresses: _defaultAddresses());

  void setUser(AppUser user) => state = state.copyWith(currentUser: user);

  void toggleFavorite(String id) {
    final favs = {...state.favoriteProviderIds};
    favs.contains(id) ? favs.remove(id) : favs.add(id);
    state = state.copyWith(favoriteProviderIds: favs);
  }

  void addHistoryItem(ServiceHistoryItem item) =>
      state = state.copyWith(history: [item, ...state.history]);

  void addUserReview(UserServiceReview review) =>
      state = state.copyWith(userReviews: [review, ...state.userReviews]);

  void setNotificationsEnabled(bool value) =>
      state = state.copyWith(notificationsEnabled: value);

  void setServiceAlertsEnabled(bool value) =>
      state = state.copyWith(serviceAlertsEnabled: value);

  void setProfileVisible(bool value) =>
      state = state.copyWith(profileVisible: value);

  void setDataSharingEnabled(bool value) =>
      state = state.copyWith(dataSharingEnabled: value);

  void addAddress(_SavedAddress address) {
    final addresses = [...state.savedAddresses, address];
    state = state.copyWith(
      savedAddresses: addresses,
      selectedAddress: addresses.length - 1,
    );
  }

  void editAddress(int index, _SavedAddress address) {
    final addresses = [...state.savedAddresses];
    addresses[index] = address;
    state = state.copyWith(savedAddresses: addresses, selectedAddress: index);
  }

  void selectAddress(int index) => state = state.copyWith(selectedAddress: index);

  void reset() => state = SessionState(savedAddresses: _defaultAddresses());
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);

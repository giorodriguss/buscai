part of '../figma_flow.dart';

class SessionState {
  final AppUser? currentUser;
  final int selectedAddress;
  final Set<String> favoriteProviderIds;
  final List<ServiceHistoryItem> history;
  final List<ScheduledService> scheduledServices;
  final List<UserServiceReview> userReviews;
  final List<AppNotification> notifications;
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
    this.scheduledServices = const [],
    this.userReviews = const [],
    this.notifications = const [],
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
    List<ScheduledService>? scheduledServices,
    List<UserServiceReview>? userReviews,
    List<AppNotification>? notifications,
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
      scheduledServices: scheduledServices ?? this.scheduledServices,
      userReviews: userReviews ?? this.userReviews,
      notifications: notifications ?? this.notifications,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      serviceAlertsEnabled: serviceAlertsEnabled ?? this.serviceAlertsEnabled,
      profileVisible: profileVisible ?? this.profileVisible,
      dataSharingEnabled: dataSharingEnabled ?? this.dataSharingEnabled,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  static const _localSessionKey = 'buscai_local_session_v1';
  bool _restoredLocalSession = false;

  static List<_SavedAddress> _defaultAddresses() => const [];

  static List<AppNotification> _defaultNotifications() => const [
        AppNotification(
          id: 'welcome',
          icon: Icons.notifications_active_outlined,
          title: 'Bem-vindo ao Buscaí',
          message:
              'Suas confirmações, avaliações e avisos de serviços aparecem aqui.',
          timeLabel: 'Agora',
        ),
        AppNotification(
          id: 'privacy',
          icon: Icons.shield_outlined,
          title: 'Segurança da conta',
          message:
              'Revise seus dados e altere a senha pela área de configurações.',
          timeLabel: 'Hoje',
          unread: false,
        ),
      ];

  @override
  SessionState build() {
    // Salvamento local temporario do prototipo. Futuro backend: substituir por
    // GET /me, GET /favorites, GET /appointments, GET /reviews e
    // GET /notifications.
    Future.microtask(_restoreLocalSession);
    return SessionState(
      savedAddresses: _defaultAddresses(),
      notifications: _defaultNotifications(),
    );
  }

  Future<void> _restoreLocalSession() async {
    if (_restoredLocalSession) return;
    _restoredLocalSession = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localSessionKey);
      if (raw == null || raw.isEmpty) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final restoredNotifications = data.containsKey('notifications')
          ? (data['notifications'] as List? ?? [])
              .map((item) => AppNotification.fromLocalJson(_jsonMap(item)))
              .toList()
          : state.notifications;
      state = state.copyWith(
        favoriteProviderIds: (data['favoriteProviderIds'] as List? ?? [])
            .whereType<String>()
            .toSet(),
        scheduledServices: (data['scheduledServices'] as List? ?? [])
            .map((service) => ScheduledService.fromLocalJson(_jsonMap(service)))
            .toList(),
        userReviews: (data['userReviews'] as List? ?? [])
            .map((review) => UserServiceReview.fromLocalJson(_jsonMap(review)))
            .toList(),
        notifications: restoredNotifications,
        savedAddresses: (data['savedAddresses'] as List? ?? [])
            .map((address) => _SavedAddress.fromLocalJson(_jsonMap(address)))
            .toList(),
        selectedAddress: (data['selectedAddress'] as num?)?.toInt() ?? 0,
        profileVisible: data['profileVisible'] as bool? ?? state.profileVisible,
      );
    } catch (_) {
      // Se o formato local antigo quebrar, mantemos o app funcional e o usuario
      // pode seguir usando; o backend real vai ser a fonte de verdade depois.
    }
  }

  Future<void> _persistLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _localSessionKey,
        jsonEncode({
          'favoriteProviderIds': state.favoriteProviderIds.toList(),
          'scheduledServices': state.scheduledServices
              .map((service) => service.toLocalJson())
              .toList(),
          'userReviews':
              state.userReviews.map((review) => review.toLocalJson()).toList(),
          'notifications': state.notifications
              .map((notification) => notification.toLocalJson())
              .toList(),
          'savedAddresses': state.savedAddresses
              .map((address) => address.toLocalJson())
              .toList(),
          'selectedAddress': state.selectedAddress,
          'profileVisible': state.profileVisible,
        }),
      );
    } catch (_) {
      // Testes unitarios sem plugin e ambientes sem storage continuam usando
      // apenas o estado em memoria.
    }
  }

  void setUser(AppUser user) => state = state.copyWith(currentUser: user);

  void toggleFavorite(String id) {
    final favs = {...state.favoriteProviderIds};
    final added = !favs.contains(id);
    added ? favs.add(id) : favs.remove(id);
    state = state.copyWith(favoriteProviderIds: favs);
    if (added) {
      _pushNotification(
        icon: Icons.favorite_border_rounded,
        title: 'Prestador salvo',
        message: 'Você adicionou um prestador aos favoritos.',
      );
    }
    _persistLocalSession();
  }

  void addHistoryItem(ServiceHistoryItem item) =>
      state = state.copyWith(history: [item, ...state.history]);

  void addScheduledService(ScheduledService service) {
    state = state.copyWith(
      scheduledServices: [service, ...state.scheduledServices],
    );
    _pushNotification(
      icon: Icons.event_available_outlined,
      title: 'Serviço pendente',
      message:
          '${service.service.name} com ${service.provider.name} foi criado para ${service.date} às ${service.hour}.',
    );
    _persistLocalSession();
  }

  void markScheduledServiceCompleted(String id) {
    state = state.copyWith(
      scheduledServices: state.scheduledServices.map((service) {
        if (service.id != id) return service;
        return service.copyWith(
          status: ScheduledServiceStatus.completed,
          waitingResidentConfirmation: false,
        );
      }).toList(),
    );
    _pushNotification(
      icon: Icons.check_circle_outline_rounded,
      title: 'Serviço realizado',
      message: 'O serviço foi marcado como realizado e já pode ser avaliado.',
    );
    _persistLocalSession();
  }

  void markScheduledServiceWaitingConfirmation(String id) {
    state = state.copyWith(
      scheduledServices: state.scheduledServices.map((service) {
        if (service.id != id) return service;
        return service.copyWith(waitingResidentConfirmation: true);
      }).toList(),
    );
    _pushNotification(
      icon: Icons.verified_user_outlined,
      title: 'Confirmação pendente',
      message:
          'O prestador marcou o atendimento como realizado. Confirme para liberar a contagem no perfil.',
    );
    _persistLocalSession();
  }

  void reviewScheduledService(String id, int rating, String comment) {
    ScheduledService? reviewedService;
    final updated = state.scheduledServices.map((service) {
      if (service.id != id) return service;
      reviewedService = service.copyWith(
        status: ScheduledServiceStatus.reviewed,
        waitingResidentConfirmation: false,
        rating: rating,
        reviewComment: comment,
      );
      return reviewedService!;
    }).toList();

    final review = reviewedService == null
        ? null
        : UserServiceReview(
            provider: reviewedService!.provider,
            service: reviewedService!.service,
            rating: rating,
            comment: comment,
            date: 'Hoje',
          );

    state = state.copyWith(
      scheduledServices: updated,
      userReviews:
          review == null ? state.userReviews : [review, ...state.userReviews],
    );
    _pushNotification(
      icon: Icons.star_border_rounded,
      title: 'Avaliação enviada',
      message: 'Sua avaliação foi publicada no perfil do prestador.',
    );
    _persistLocalSession();
  }

  void addUserReview(UserServiceReview review) {
    state = state.copyWith(userReviews: [review, ...state.userReviews]);
    _persistLocalSession();
  }

  void addNotification(AppNotification notification) {
    state =
        state.copyWith(notifications: [notification, ...state.notifications]);
    _persistLocalSession();
  }

  void markNotificationRead(String id) {
    state = state.copyWith(
      notifications: state.notifications
          .map((item) => item.id == id ? item.copyWith(unread: false) : item)
          .toList(),
    );
    _persistLocalSession();
  }

  void markAllNotificationsRead() {
    state = state.copyWith(
      notifications: state.notifications
          .map((item) => item.copyWith(unread: false))
          .toList(),
    );
    _persistLocalSession();
  }

  void _pushNotification({
    required IconData icon,
    required String title,
    required String message,
  }) {
    if (!state.notificationsEnabled) return;
    state = state.copyWith(
      notifications: [
        AppNotification(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          icon: icon,
          title: title,
          message: message,
          timeLabel: 'Agora',
        ),
        ...state.notifications,
      ],
    );
  }

  void setNotificationsEnabled(bool value) =>
      state = state.copyWith(notificationsEnabled: value);

  void setServiceAlertsEnabled(bool value) =>
      state = state.copyWith(serviceAlertsEnabled: value);

  void setProfileVisible(bool value) {
    state = state.copyWith(profileVisible: value);
    _persistLocalSession();
  }

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

  void selectAddress(int index) =>
      state = state.copyWith(selectedAddress: index);

  void reset() {
    state = SessionState(
      savedAddresses: _defaultAddresses(),
      notifications: _defaultNotifications(),
    );
    SharedPreferences.getInstance()
        .then((prefs) => prefs.remove(_localSessionKey))
        .catchError((_) => false);
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);

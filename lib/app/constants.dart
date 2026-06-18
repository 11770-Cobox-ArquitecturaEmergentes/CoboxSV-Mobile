class AppConstants {
  AppConstants._();

  static const String appName = 'CoBox SV';
  static const String appVersion = '1.0.0';
  static const int buildNumber = 1;

  static const int pageSize = 20;
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const int cacheMaxAgeDays = 7;

  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String dateTimeFullFormat = "yyyy-MM-dd'T'HH:mm:ss";
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String displayDateTimeFormat = 'dd MMM yyyy, HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";

  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 300);

  static const Duration debounceDuration = Duration(milliseconds: 300);
  static const Duration searchDelay = Duration(milliseconds: 500);
  static const Duration locationUpdateInterval = Duration(seconds: 30);
  static const Duration syncInterval = Duration(minutes: 5);
  static const Duration sessionTimeout = Duration(hours: 8);

  static const String storageThemeMode = 'theme_mode';
  static const String storageAuthToken = 'auth_token';
  static const String storageRefreshToken = 'auth_refresh_token';
  static const String storageUserData = 'auth_user_data';
  static const String storageOnboardingComplete = 'onboarding_complete';
  static const String storageLastSync = 'last_sync';
  static const String storageLanguage = 'language';
  static const String storageNotificationToken = 'notification_token';
  static const String storageDraftIncidents = 'draft_incidents';
  static const String storageCachedRoutes = 'cached_routes';
  static const String storageCachedOrders = 'cached_orders';
  static const String storageLocationCache = 'location_cache';

  static const String routeSplash = '/splash';
  static const String routeLogin = '/login';
  static const String routeHome = '/home';
  static const String routePlanning = '/planning';
  static const String routeRoutes = '/routes';
  static const String routeRouteDetail = '/routes/:id';
  static const String routeOrders = '/orders';
  static const String routeOrderDetail = '/orders/:id';
  static const String routeIncidents = '/incidents';
  static const String routeIncidentDetail = '/incidents/:id';
  static const String routeProfile = '/profile';
  static const String routeNotifications = '/notifications';

  static const String vehicleTypeTruck = 'TRUCK';
  static const String vehicleTypeVan = 'VAN';
  static const String vehicleTypeTrailer = 'TRAILER';
  static const String vehicleTypePickup = 'PICKUP';
  static const String vehicleTypeMotorcycle = 'MOTORCYCLE';

  static const List<String> vehicleTypes = [
    vehicleTypeTruck,
    vehicleTypeVan,
    vehicleTypeTrailer,
    vehicleTypePickup,
    vehicleTypeMotorcycle,
  ];

  static const String orderStatusPending = 'PENDING';
  static const String orderStatusConfirmed = 'CONFIRMED';
  static const String orderStatusInTransit = 'IN_TRANSIT';
  static const String orderStatusDelivered = 'DELIVERED';
  static const String orderStatusCancelled = 'CANCELLED';
  static const String orderStatusReturned = 'RETURNED';

  static const List<String> orderStatuses = [
    orderStatusPending,
    orderStatusConfirmed,
    orderStatusInTransit,
    orderStatusDelivered,
    orderStatusCancelled,
    orderStatusReturned,
  ];

  static const String routeStatusPlanned = 'PLANNED';
  static const String routeStatusInProgress = 'IN_PROGRESS';
  static const String routeStatusCompleted = 'COMPLETED';
  static const String routeStatusCancelled = 'CANCELLED';

  static const List<String> routeStatuses = [
    routeStatusPlanned,
    routeStatusInProgress,
    routeStatusCompleted,
    routeStatusCancelled,
  ];

  static const String deliveryStatusPending = 'PENDING';
  static const String deliveryStatusInTransit = 'IN_TRANSIT';
  static const String deliveryStatusDelivered = 'DELIVERED';
  static const String deliveryStatusFailed = 'FAILED';

  static const String incidentTypeAccident = 'ACCIDENT';
  static const String incidentTypeDelay = 'DELAY';
  static const String incidentTypeDamage = 'DAMAGE';
  static const String incidentTypeLoss = 'LOSS';
  static const String incidentTypeTheft = 'THEFT';
  static const String incidentTypeTraffic = 'TRAFFIC';
  static const String incidentTypeWeather = 'WEATHER';
  static const String incidentTypeMechanical = 'MECHANICAL';
  static const String incidentTypeOther = 'OTHER';

  static const List<String> incidentTypes = [
    incidentTypeAccident,
    incidentTypeDelay,
    incidentTypeDamage,
    incidentTypeLoss,
    incidentTypeTheft,
    incidentTypeTraffic,
    incidentTypeWeather,
    incidentTypeMechanical,
    incidentTypeOther,
  ];
}

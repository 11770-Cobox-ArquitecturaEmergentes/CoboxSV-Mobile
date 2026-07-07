class Endpoints {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.coboxsv.com/api/v1',
  );

  static const String dashboard = '/drivers/{driverId}/dashboard';
  static const String recentActivity = '/drivers/{driverId}/activity';

  static const String plans = '/drivers/{driverId}/plans';
  static const String planDetail = '/drivers/{driverId}/plans/';

  static const String routes = '/routes';
  static const String routeDetail = '/routes/';
  static const String driverRoutesTemplate = '/drivers/{driverId}/routes';
  static const String routeStops = '/routes/';
  static const String startRoute = '/routes/';
  static const String completeStop = '/routes/';

  static const String orders = '/orders';
  static const String orderDetail = '/orders/';
  static const String updateOrderStatus = '/orders/';

  static const String incidents = '/incidents';
  static const String incidentDetail = '/incidents/';
  static const String createIncident = '/incidents';
  static const String incidentTypes = '/incidents/types';
  static const String uploadEvidence = '/incidents/upload';

  static const String mobileEvidenceUploadIntents =
      '/mobile/evidence/upload-intents';
  static const String edgeSyncBatches = '/edge/sync-batches';

  static const String profile = '/profile';
  static const String updateProfile = '/profile';
  static const String uploadPhoto = '/profile/photo';
  static const String vehicleInfo = '/profile/vehicle';

  static const String notifications = '/notifications';
  static const String markRead = '/notifications/';
  static const String markAllRead = '/notifications/read-all';

  static const String users = '/users';
  static const String currentUser = '/users/me';
  static const String vehicles = '/vehicles';
  static const String documents = '/documents';

  static const String drivers = '/drivers';
  static const String driverSearch = '/drivers/search';

  static String driverRoutes(String driverId) => '/drivers/$driverId/routes';
}

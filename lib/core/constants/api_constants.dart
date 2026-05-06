class ApiConstants {
  // Host configurations:
  // Android Emulator: 10.0.2.2
  // iOS Simulator: 127.0.0.1 or localhost
  // Physical Device: Use your machine's LAN IP (e.g., 192.168.1.5)
  static const String _host = '127.0.0.1'; // Change this as needed
  static const String _port = '8081';
  
  static const String baseUrl = 'http://$_host:$_port/api';

  // Field Mentor Endpoints
  static const String fieldMentors = '/fieldmentors';
  static const String bins = '/bins';

  // Collection request endpoints
  static const String citizens = '/citizens';
  static const String collectionRequests = '/collection-requests';
  static const String offers = '/offers';
  static const String thirdPartyCollectors = '/thirdpartycollectors';

  // User and Auth endpoints
  static const String auth = '/auth';
  static const String users = '/users';

  // Third-party collector registration (public, no auth)
  static const String thirdPartyRegister = '/auth/thirdparty-register';
}

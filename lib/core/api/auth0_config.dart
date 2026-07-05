class Auth0Config {
  static const String issuerUri = String.fromEnvironment(
    'AUTH0_ISSUER_URI',
    defaultValue: 'https://dev-e5ik5gbwpzkcqfrw.us.auth0.com/',
  );

  static const String clientId = String.fromEnvironment(
    'AUTH0_CLIENT_ID',
    defaultValue: '',
  );

  static const String audience = String.fromEnvironment(
    'AUTH0_AUDIENCE',
    defaultValue: 'https://api.coboxsv.dev',
  );

  static const String connection = String.fromEnvironment(
    'AUTH0_CONNECTION',
    defaultValue: 'Username-Password-Authentication',
  );

  static String get normalizedIssuer =>
      issuerUri.endsWith('/') ? issuerUri : '$issuerUri/';

  static String get oauthTokenUrl => '${normalizedIssuer}oauth/token';

  static String get signupUrl => '${normalizedIssuer}dbconnections/signup';

  static bool get isConfigured => clientId.trim().isNotEmpty;
}

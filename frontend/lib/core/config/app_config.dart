class AppConfig {
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000',
  );
  static const issuer = String.fromEnvironment(
    'OIDC_ISSUER',
    defaultValue: 'http://localhost:8081/realms/fincontrol',
  );
  static const clientId = 'fincontrol-mobile';
  static const redirectUrl = 'br.com.fincontrol:/oauthredirect';
}

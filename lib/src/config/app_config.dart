class AppConfig {
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );

  static const environmentLabel = String.fromEnvironment(
    'ENV_LABEL',
    defaultValue: 'DEV',
  );
}

/// Centralized branding and product configuration for Kerdos.
///
/// Every product name, tagline, and identity string used anywhere in the
/// app must be read from this file. Changing a value here changes it
/// everywhere the app is built and run.
class AppConfig {
  AppConfig._();

  static const String productName = 'Kerdos';

  static const String productTagline =
      "See who's really carrying the group's risk.";

  static const String lenderPortalName = 'Lender Portal';

  static const String borrowerPortalName = 'Borrower Portal';

  /// Base URL for the FastAPI backend. The mock data layer is used until
  /// [useMockData] is flipped to false and this points at a live server.
  static const String apiBaseUrl = String.fromEnvironment(
    'KERDOS_API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const bool useMockData = true;

  static const List<String> supportedLocales = [
    'en',
    'hi',
    'ta',
    'te',
    'kn',
    'bn',
  ];
}
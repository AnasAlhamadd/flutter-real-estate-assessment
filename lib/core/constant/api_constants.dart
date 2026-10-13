abstract final class ApiConstants {
  /// Override with `--dart-define=API_BASE_URL=https://...`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://dummyjson.com',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const int pageSize = 20;

  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String categories = '/products/categories';

  static String productsByCategory(String slug) => '/products/category/$slug';

  static String productById(int id) => '/products/$id';
}

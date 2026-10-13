/// SharedPreferences keys. `locale` is reserved by easy_localization.
abstract final class StorageKeys {
  static const String productsFirstPage = 'cache.products.first_page';
  static const String categories = 'cache.categories';

  /// Favorite listing snapshots (Q8, approved 2026-10-13). User data, not a
  /// cache: never expires.
  static const String favorites = 'favorites';
}

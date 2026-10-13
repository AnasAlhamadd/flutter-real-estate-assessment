/// Search text rules shared by the cubit (when to search) and the
/// repository (cache key), so both always agree on the same query.
abstract final class SearchQuery {
  /// Shorter normalized queries never reach the API.
  static const int minLength = 2;

  static final RegExp _whitespace = RegExp(r'\s+');

  /// Trimmed, inner whitespace collapsed to one space, lower case. DummyJSON
  /// search is case-insensitive, so "Ca" and "ca" share one cache entry.
  static String normalize(String text) =>
      text.trim().replaceAll(_whitespace, ' ').toLowerCase();

  /// Whether the already [normalize]d [query] is long enough to search.
  static bool isSearchable(String query) => query.runes.length >= minLength;
}

/// Where the shown data came from.
enum DataSource {
  /// A successful API response.
  remote,

  /// The persisted copy, shown when the API couldn't be reached (offline).
  /// Pagination waits until a refresh gets [remote] data again.
  saved,
}

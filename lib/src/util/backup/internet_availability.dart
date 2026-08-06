import 'internet_availability_stub.dart' if (dart.library.io) 'internet_availability_io.dart' as implementation;

/// Checks whether Dropbox's API endpoint can currently be reached.
Future<bool> isDropboxInternetAvailable(Duration timeout) {
  return implementation.isDropboxInternetAvailable(timeout);
}

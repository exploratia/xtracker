import 'dropbox_client_adapter_stub.dart' if (dart.library.io) 'dropbox_client_adapter_io.dart' as implementation;

/// Platform-neutral subset of Dropbox operations used by the backup feature.
abstract interface class DropboxClientAdapter {
  /// Initializes the native Dropbox SDK.
  Future<void> init(String clientId, String appKey, String appSecret);

  /// Opens the native PKCE authorization flow.
  Future<void> authorizePkce();

  /// Restores previously serialized OAuth credentials.
  Future<void> authorizeWithCredentials(String credentials);

  /// Returns the currently available serialized OAuth credentials.
  Future<String?> getCredentials();

  /// Removes the active native authorization.
  Future<void> unlink();

  /// Uploads a local file to [dropboxPath].
  Future<void> upload(String localFilePath, String dropboxPath);

  /// Lists files and folders below [path].
  Future<Object?> listFolder(String path);
}

/// Creates the native adapter, or an unsupported stub on web.
DropboxClientAdapter createDropboxClientAdapter() {
  return implementation.createDropboxClientAdapter();
}

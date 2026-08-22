import 'dropbox_client_adapter.dart';

class _UnsupportedDropboxClientAdapter implements DropboxClientAdapter {
  Never _unsupported() => throw UnsupportedError('Dropbox backup is not available on this platform.');

  @override
  Future<void> init(String clientId, String appKey, String appSecret) async => _unsupported();

  @override
  Future<void> authorizePkce() async => _unsupported();

  @override
  Future<void> authorizeWithCredentials(String credentials) async => _unsupported();

  @override
  Future<String?> getCredentials() async => _unsupported();

  @override
  Future<void> unlink() async => _unsupported();

  @override
  Future<void> upload(String localFilePath, String dropboxPath) async => _unsupported();

  @override
  Future<Object?> listFolder(String path) async => _unsupported();
}

DropboxClientAdapter createDropboxClientAdapter() => _UnsupportedDropboxClientAdapter();

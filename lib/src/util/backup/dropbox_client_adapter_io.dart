import 'package:dropbox_client/dropbox_client.dart';

import 'dropbox_client_adapter.dart';

class _DropboxClientAdapterIo implements DropboxClientAdapter {
  @override
  Future<void> init(String clientId, String appKey, String appSecret) async {
    await Dropbox.init(clientId, appKey, appSecret);
  }

  @override
  Future<void> authorizePkce() => Dropbox.authorizePKCE();

  @override
  Future<void> authorizeWithCredentials(String credentials) => Dropbox.authorizeWithCredentials(credentials);

  @override
  Future<String?> getCredentials() => Dropbox.getCredentials();

  @override
  Future<void> unlink() => Dropbox.unlink();

  @override
  Future<void> upload(String localFilePath, String dropboxPath) async {
    await Dropbox.upload(localFilePath, dropboxPath);
  }

  @override
  Future<Object?> listFolder(String path) => Dropbox.listFolder(path);
}

DropboxClientAdapter createDropboxClientAdapter() => _DropboxClientAdapterIo();

import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/backup/dropbox_backup_service.dart';
import 'package:xtracker/src/util/backup/dropbox_client_adapter.dart';

void main() {
  test('initializes PKCE without an app secret', () async {
    final client = _FakeDropboxClient();
    final service = DropboxBackupService(client: client, appKey: 'public-app-key');

    await service.ensureInitialized();

    expect(client.clientId, 'xtracker');
    expect(client.appKey, 'public-app-key');
    expect(client.appSecret, isEmpty);
  });

  test('verifies an uploaded backup through the plugin folder listing', () async {
    final client = _FakeDropboxClient();
    final service = DropboxBackupService(client: client, appKey: 'public-app-key');

    await service.uploadBackup('local.json', '/xtracker_backup_20260731.json');

    expect(client.uploadedPath, '/xtracker_backup_20260731.json');
  });

  test('fails if the plugin does not list the uploaded backup', () async {
    final client = _FakeDropboxClient(listUploadedFile: false);
    final service = DropboxBackupService(client: client, appKey: 'public-app-key');

    await expectLater(
      service.uploadBackup('local.json', '/xtracker_backup_20260731.json'),
      throwsA(isA<StateError>()),
    );
  });
}

class _FakeDropboxClient implements DropboxClientAdapter {
  _FakeDropboxClient({this.listUploadedFile = true});

  final bool listUploadedFile;
  String? clientId;
  String? appKey;
  String? appSecret;
  String? uploadedPath;

  @override
  Future<void> init(String clientId, String appKey, String appSecret) async {
    this.clientId = clientId;
    this.appKey = appKey;
    this.appSecret = appSecret;
  }

  @override
  Future<void> upload(String localFilePath, String dropboxPath) async {
    uploadedPath = dropboxPath;
  }

  @override
  Future<Object?> listFolder(String path) async {
    if (!listUploadedFile) return <Object>[];
    return <Object>[
      <String, Object>{'name': 'xtracker_backup_20260731.json'},
    ];
  }

  @override
  Future<void> authorizePkce() async {}

  @override
  Future<void> authorizeWithCredentials(String credentials) async {}

  @override
  Future<String?> getCredentials() async => null;

  @override
  Future<void> unlink() async {}
}

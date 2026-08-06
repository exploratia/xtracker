import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/backup/dropbox_backup_service.dart';
import 'package:xtracker/src/util/backup/dropbox_client_adapter.dart';
import 'package:xtracker/src/util/device_storage/device_storage_keys.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('reports when the Dropbox endpoint is unavailable', () async {
    final service = DropboxBackupService(
      client: _FakeDropboxClient(),
      internetAvailabilityChecker: (_) async => false,
    );

    expect(await service.hasInternetConnection(), isFalse);
  });

  test('times out a Dropbox upload that does not complete', () async {
    final client = _FakeDropboxClient(uploadCompleter: Completer<void>());
    final service = DropboxBackupService(
      client: client,
      operationTimeout: const Duration(milliseconds: 10),
    );

    await expectLater(
      service.uploadBackup('local.json', '/xtracker_backup_20260731.json'),
      throwsA(isA<TimeoutException>()),
    );
  });

  test('times out restoring Dropbox authorization', () async {
    FlutterSecureStorage.setMockInitialValues({DeviceStorageKeys.dropboxCredentials: 'stored'});
    final client = _FakeDropboxClient(authorizationCompleter: Completer<void>());
    final service = DropboxBackupService(
      client: client,
      operationTimeout: const Duration(milliseconds: 10),
    );

    await expectLater(service.isAuthorized(), throwsA(isA<TimeoutException>()));
  });
}

class _FakeDropboxClient implements DropboxClientAdapter {
  _FakeDropboxClient({this.listUploadedFile = true, this.uploadCompleter, this.authorizationCompleter});

  final bool listUploadedFile;
  final Completer<void>? uploadCompleter;
  final Completer<void>? authorizationCompleter;
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
    await uploadCompleter?.future;
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
  Future<void> authorizeWithCredentials(String credentials) async {
    await authorizationCompleter?.future;
  }

  @override
  Future<String?> getCredentials() async => 'refreshed';

  @override
  Future<void> unlink() async {}
}

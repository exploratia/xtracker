import 'package:flutter/foundation.dart';

import '../device_storage/device_storage.dart';
import '../device_storage/device_storage_keys.dart';
import '../logging/flutter_simple_logging.dart';
import 'dropbox_client_adapter.dart';

/// Upload target used by [AutoBackupManager].
abstract interface class BackupUploader {
  Future<void> uploadBackup(String localFilePath, String dropboxPath);
}

/// Handles authentication and file operations through the Dropbox plugin.
class DropboxBackupService implements BackupUploader {
  DropboxBackupService({
    DropboxClientAdapter? client,
    String appKey = '1zm0mwzq0j3bgz4',
  }) : _client = client ?? createDropboxClientAdapter(),
       _appKey = appKey;

  static final instance = DropboxBackupService();

  static const _clientId = 'xtracker';

  final DropboxClientAdapter _client;
  final String _appKey;
  bool _initialized = false;

  /// Whether the current platform has native Dropbox support.
  bool get isAvailable => !kIsWeb;

  /// Whether an app key was supplied at compile time.
  bool get isConfigured => _appKey.isNotEmpty;

  /// Initializes the native SDK once. PKCE deliberately uses no app secret.
  Future<void> ensureInitialized() async {
    if (_initialized || !isAvailable) return;
    if (!isConfigured) {
      throw StateError('Dropbox app key is not configured.');
    }
    await _client.init(_clientId, _appKey, '');
    _initialized = true;
    SimpleLogging.i('Dropbox backup service initialized.');
  }

  /// Restores stored credentials without showing interactive UI.
  Future<bool> isAuthorized() async {
    if (!isAvailable) return false;
    final storedCredentials = await DeviceStorage.read(DeviceStorageKeys.dropboxCredentials);
    if (storedCredentials == null || storedCredentials.isEmpty) return false;

    try {
      await ensureInitialized();
      await _client.authorizeWithCredentials(storedCredentials);
      final refreshedCredentials = await _client.getCredentials();
      if (refreshedCredentials == null || refreshedCredentials.isEmpty) return false;
      await DeviceStorage.write(DeviceStorageKeys.dropboxCredentials, refreshedCredentials);
      return true;
    } catch (error, stackTrace) {
      SimpleLogging.w('Restoring Dropbox authorization failed.', error: error, stackTrace: stackTrace);
      return false;
    }
  }

  /// Opens the Dropbox PKCE authorization flow.
  Future<void> beginInteractiveAuthorization() async {
    await ensureInitialized();
    await _client.authorizePkce();
  }

  /// Persists credentials after the native authorization activity returns.
  Future<bool> completeInteractiveAuthorization() async {
    final credentials = await _client.getCredentials();
    if (credentials == null || credentials.isEmpty) return false;
    await DeviceStorage.write(DeviceStorageKeys.dropboxCredentials, credentials);
    SimpleLogging.i('Dropbox authorization completed.');
    return true;
  }

  /// Unlinks Dropbox and removes locally persisted credentials.
  Future<void> unlink() async {
    try {
      if (_initialized) await _client.unlink();
    } finally {
      await DeviceStorage.delete(DeviceStorageKeys.dropboxCredentials);
      SimpleLogging.i('Dropbox authorization removed.');
    }
  }

  /// Uploads a backup and verifies that Dropbox lists the target afterwards.
  @override
  Future<void> uploadBackup(String localFilePath, String dropboxPath) async {
    await ensureInitialized();
    SimpleLogging.i('Uploading automatic backup to $dropboxPath.');
    await _client.upload(localFilePath, dropboxPath);

    final fileNames = await listBackupFileNames();
    final expectedName = dropboxPath.split('/').last;
    if (!fileNames.contains(expectedName)) {
      throw StateError('Dropbox did not confirm uploaded backup $expectedName.');
    }
    SimpleLogging.i('Automatic backup upload verified.');
  }

  /// Lists automatic backup files in the Dropbox app folder.
  Future<List<String>> listBackupFileNames() async {
    final response = await _client.listFolder('');
    if (response is! List) {
      throw StateError('Dropbox folder listing failed: $response');
    }

    return response
        .whereType<Map>()
        .map((entry) => entry['name'])
        .whereType<String>()
        .where((name) => name.startsWith('xtracker_backup_') && name.endsWith('.json'))
        .toList(growable: false);
  }
}

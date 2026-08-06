import 'dart:async';

import 'package:flutter/foundation.dart';

import '../device_storage/device_storage.dart';
import '../device_storage/device_storage_keys.dart';
import '../logging/flutter_simple_logging.dart';
import 'dropbox_client_adapter.dart';
import 'internet_availability.dart';

typedef InternetAvailabilityChecker = Future<bool> Function(Duration timeout);

/// Upload target used by [AutoBackupManager].
abstract interface class BackupUploader {
  Future<void> uploadBackup(String localFilePath, String dropboxPath);
}

/// Handles authentication and file operations through the Dropbox plugin.
class DropboxBackupService implements BackupUploader {
  DropboxBackupService({
    DropboxClientAdapter? client,
    String appKey = '1zm0mwzq0j3bgz4',
    InternetAvailabilityChecker? internetAvailabilityChecker,
    this.connectionTimeout = const Duration(seconds: 5),
    this.operationTimeout = const Duration(seconds: 30),
  }) : _client = client ?? createDropboxClientAdapter(),
       _appKey = appKey,
       _internetAvailabilityChecker = internetAvailabilityChecker ?? isDropboxInternetAvailable;

  static final instance = DropboxBackupService();

  static const _clientId = 'xtracker';

  final DropboxClientAdapter _client;
  final String _appKey;
  final InternetAvailabilityChecker _internetAvailabilityChecker;
  final Duration connectionTimeout;
  final Duration operationTimeout;
  bool _initialized = false;

  /// Whether the current platform has native Dropbox support.
  bool get isAvailable => !kIsWeb;

  /// Whether an app key was supplied at compile time.
  bool get isConfigured => _appKey.isNotEmpty;

  /// Whether the Dropbox API endpoint is reachable within [connectionTimeout].
  Future<bool> hasInternetConnection() async {
    try {
      return await _internetAvailabilityChecker(connectionTimeout);
    } catch (error, stackTrace) {
      SimpleLogging.w('Dropbox connectivity check failed.', error: error, stackTrace: stackTrace);
      return false;
    }
  }

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
      final refreshedCredentials = await (() async {
        await ensureInitialized();
        await _client.authorizeWithCredentials(storedCredentials);
        return _client.getCredentials();
      })().timeout(operationTimeout);
      if (refreshedCredentials == null || refreshedCredentials.isEmpty) return false;
      await DeviceStorage.write(DeviceStorageKeys.dropboxCredentials, refreshedCredentials);
      return true;
    } on TimeoutException catch (error, stackTrace) {
      SimpleLogging.w('Restoring Dropbox authorization timed out.', error: error, stackTrace: stackTrace);
      rethrow;
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
    await (() async {
      await ensureInitialized();
      SimpleLogging.i('Uploading automatic backup to $dropboxPath.');
      await _client.upload(localFilePath, dropboxPath);

      final fileNames = await listBackupFileNames();
      final expectedName = dropboxPath.split('/').last;
      if (!fileNames.contains(expectedName)) {
        throw StateError('Dropbox did not confirm uploaded backup $expectedName.');
      }
      SimpleLogging.i('Automatic backup upload verified.');
    })().timeout(operationTimeout);
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

import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/pending_app_actions.dart';

void main() {
  group('PendingAppActions', () {
    setUp(PendingAppActions.resetForTests);

    test('keeps in-app messages passive and in creation order', () {
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'notification-series',
        source: PendingSeriesActionSource.notification,
      );
      PendingAppActions.enqueueBackupReminder();
      PendingAppActions.enqueueDebugDummyAction();

      expect(PendingAppActions.count, 3);
      expect(PendingAppActions.hasPendingExternalSeriesAction, false);
      expect(PendingAppActions.hasAutomaticAction, false);
      expect(PendingAppActions.takeNextAutomaticAction(), null);
      expect(PendingAppActions.items().map((item) => item.type), [
        PendingAppActionType.seriesValue,
        PendingAppActionType.backupReminder,
        PendingAppActionType.debugDummy,
      ]);
    });

    test('deduplicates backup reminder in current app run', () {
      PendingAppActions.enqueueBackupReminder();
      PendingAppActions.enqueueBackupReminder();

      expect(PendingAppActions.count, 1);
      expect(PendingAppActions.items().single.type, PendingAppActionType.backupReminder);

      PendingAppActions.remove(PendingAppActions.items().single.id);
      PendingAppActions.enqueueBackupReminder();

      expect(PendingAppActions.count, 0);
    });

    test('deduplicates notification messages by notification id', () {
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'series-1',
        source: PendingSeriesActionSource.notification,
        notificationId: 123,
      );
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'series-1',
        source: PendingSeriesActionSource.notification,
        notificationId: 123,
      );

      expect(PendingAppActions.count, 1);

      PendingAppActions.remove(PendingAppActions.items().single.id);
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'series-1',
        source: PendingSeriesActionSource.notification,
        notificationId: 123,
      );

      expect(PendingAppActions.count, 0);
    });

    test('executes only directly requested quick action', () {
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'notification-series',
        source: PendingSeriesActionSource.notification,
      );
      PendingAppActions.enqueueBackupReminder();
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'quick-action-series',
        source: PendingSeriesActionSource.quickAction,
        executeAutomatically: true,
      );

      expect(PendingAppActions.count, 2);
      expect(PendingAppActions.hasPendingExternalSeriesAction, true);
      expect(PendingAppActions.hasAutomaticAction, true);

      var directAction = PendingAppActions.takeNextAutomaticAction();

      expect(directAction?.seriesUuid, 'quick-action-series');
      expect(PendingAppActions.hasAutomaticAction, false);
      expect(PendingAppActions.takeNextAutomaticAction(), null);
      expect(PendingAppActions.count, 2);
    });

    test('notification tap consumes matching message and executes directly', () {
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'series-1',
        source: PendingSeriesActionSource.notification,
        notificationId: 123,
      );
      PendingAppActions.enqueueBackupReminder();
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'series-1',
        source: PendingSeriesActionSource.notification,
        notificationId: 123,
        executeAutomatically: true,
      );

      expect(PendingAppActions.count, 1);
      expect(PendingAppActions.items().single.type, PendingAppActionType.backupReminder);

      var directAction = PendingAppActions.takeNextAutomaticAction();

      expect(directAction?.seriesUuid, 'series-1');
      expect(directAction?.notificationId, 123);
    });

    test('removes messages for Android notifications that are no longer active', () {
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'series-1',
        source: PendingSeriesActionSource.notification,
        notificationId: 123,
      );
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'series-2',
        source: PendingSeriesActionSource.notification,
        notificationId: 456,
      );
      PendingAppActions.enqueueBackupReminder();

      PendingAppActions.retainActiveNotificationActions({456});

      expect(PendingAppActions.count, 2);
      expect(PendingAppActions.items().where((item) => item.notificationId != null).single.notificationId, 456);
      expect(PendingAppActions.items().any((item) => item.type == PendingAppActionType.backupReminder), true);
    });

    test('does not expose quick actions as visible messages', () {
      PendingAppActions.enqueueBackupReminder();
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'quick-action-series',
        source: PendingSeriesActionSource.quickAction,
        executeAutomatically: true,
      );

      expect(PendingAppActions.count, 1);
      expect(PendingAppActions.items().single.type, PendingAppActionType.backupReminder);
    });

    test('never classifies a backup reminder as a direct action', () {
      var backupReminder = PendingAppAction(
        id: 'backup-reminder',
        type: PendingAppActionType.backupReminder,
        executeAutomatically: true,
        createdAt: DateTime(2026),
      );

      expect(backupReminder.isDirectSeriesAction, false);
    });
  });
}

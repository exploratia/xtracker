import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/pending_app_actions.dart';

void main() {
  group('PendingAppActions', () {
    setUp(PendingAppActions.resetForTests);

    test('orders actions by priority and keeps overflow pending', () {
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'notification-series',
        source: PendingSeriesActionSource.notification,
      );
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'quick-action-series',
        source: PendingSeriesActionSource.quickAction,
      );
      PendingAppActions.enqueueBackupReminder();
      PendingAppActions.enqueueDebugDummyActionForTests();

      expect(PendingAppActions.count, 4);
      expect(PendingAppActions.hasPendingExternalSeriesAction, true);
      expect(PendingAppActions.pendingExternalSeriesActionVersion(), 2);

      var items = PendingAppActions.items();
      expect(items[0].seriesUuid, 'quick-action-series');
      expect(items[0].seriesSource, PendingSeriesActionSource.quickAction);
      expect(items[1].seriesUuid, 'notification-series');
      expect(items[1].seriesSource, PendingSeriesActionSource.notification);
      expect(items[2].type, PendingAppActionType.backupReminder);
      expect(items[3].type, PendingAppActionType.debugDummy);

      var automaticAction = PendingAppActions.takeNextAutomaticAction();
      expect(automaticAction?.seriesUuid, 'quick-action-series');
      expect(PendingAppActions.items().map((item) => item.type), [
        PendingAppActionType.seriesValue,
        PendingAppActionType.backupReminder,
        PendingAppActionType.debugDummy,
      ]);

      PendingAppActions.completeAutomaticAction();

      expect(PendingAppActions.takeNextAutomaticAction(), null);
      expect(PendingAppActions.count, 3);
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

    test('deduplicates notification actions by notification id', () {
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

      var action = PendingAppActions.takeNextAutomaticAction();
      expect(action?.notificationId, 123);

      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'series-1',
        source: PendingSeriesActionSource.notification,
        notificationId: 123,
      );

      expect(PendingAppActions.count, 0);
    });

    test('executes explicitly requested action even while automatic actions are blocked', () {
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'old-notification-series',
        source: PendingSeriesActionSource.notification,
      );
      PendingAppActions.enqueueBackupReminder();

      var firstAction = PendingAppActions.takeNextAutomaticAction();
      expect(firstAction?.seriesUuid, 'old-notification-series');
      PendingAppActions.completeAutomaticAction();
      expect(PendingAppActions.takeNextAutomaticAction(), null);

      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'direct-quick-action-series',
        source: PendingSeriesActionSource.quickAction,
        executeAutomatically: true,
      );

      expect(PendingAppActions.count, 1);
      var directAction = PendingAppActions.takeNextAutomaticAction();
      expect(directAction?.seriesUuid, 'direct-quick-action-series');
      PendingAppActions.completeAutomaticAction();
      expect(PendingAppActions.items().map((item) => item.type), [
        PendingAppActionType.backupReminder,
      ]);
      expect(PendingAppActions.takeNextAutomaticAction(), null);
    });

    test('marks already queued notification action for automatic execution when tapped', () {
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'series-1',
        source: PendingSeriesActionSource.notification,
        notificationId: 123,
      );
      PendingAppActions.enqueueBackupReminder();

      var firstAction = PendingAppActions.takeNextAutomaticAction();
      expect(firstAction?.seriesUuid, 'series-1');
      PendingAppActions.completeAutomaticAction();
      expect(PendingAppActions.takeNextAutomaticAction(), null);

      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'series-2',
        source: PendingSeriesActionSource.notification,
        notificationId: 456,
      );
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'series-2',
        source: PendingSeriesActionSource.notification,
        notificationId: 456,
        executeAutomatically: true,
      );

      expect(PendingAppActions.count, 1);
      expect(PendingAppActions.items().single.type, PendingAppActionType.backupReminder);
      var directAction = PendingAppActions.takeNextAutomaticAction();
      expect(directAction?.seriesUuid, 'series-2');
      expect(directAction?.notificationId, 456);
    });

    test('does not expose quick actions as visible pending actions', () {
      PendingAppActions.enqueueBackupReminder();
      PendingAppActions.enqueueSeriesValue(
        seriesUuid: 'quick-action-series',
        source: PendingSeriesActionSource.quickAction,
        executeAutomatically: true,
      );

      expect(PendingAppActions.count, 1);
      expect(PendingAppActions.items().single.type, PendingAppActionType.backupReminder);

      var directAction = PendingAppActions.takeNextAutomaticAction();
      expect(directAction?.seriesUuid, 'quick-action-series');
      expect(PendingAppActions.count, 1);
    });
  });
}

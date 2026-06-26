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

      expect(PendingAppActions.count, 3);
      expect(PendingAppActions.hasPendingExternalSeriesAction, true);
      expect(PendingAppActions.pendingExternalSeriesActionVersion(), 2);

      var items = PendingAppActions.items();
      expect(items[0].seriesUuid, 'quick-action-series');
      expect(items[0].seriesSource, PendingSeriesActionSource.quickAction);
      expect(items[1].seriesUuid, 'notification-series');
      expect(items[1].seriesSource, PendingSeriesActionSource.notification);
      expect(items[2].type, PendingAppActionType.backupReminder);

      var automaticAction = PendingAppActions.takeNextAutomaticAction();
      expect(automaticAction?.seriesUuid, 'quick-action-series');
      expect(PendingAppActions.items().map((item) => item.type), [
        PendingAppActionType.seriesValue,
        PendingAppActionType.backupReminder,
      ]);

      PendingAppActions.completeAutomaticAction();

      expect(PendingAppActions.takeNextAutomaticAction(), null);
      expect(PendingAppActions.count, 2);
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
  });
}

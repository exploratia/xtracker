package de.exploratia.xtracker

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertSame
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [28], manifest = Config.NONE)
class MainActivityTest {
    @Test
    fun quickActionReplacesPreviousNotificationLaunch() {
        val activity = activityWithPreviousNotification()
        val quickAction = Intent(Intent.ACTION_RUN)
            .putExtra("some unique action key", "series_add_series-2")

        deliverIntent(activity, quickAction)

        assertSame(quickAction, activity.intent)
        assertEquals("series_add_series-2", activity.intent.getStringExtra("some unique action key"))
        assertFalse(activity.intent.hasExtra("notificationId"))
        assertFalse(activity.intent.hasExtra("payload"))
    }

    @Test
    fun normalLaunchReplacesPreviousNotificationLaunch() {
        val activity = activityWithPreviousNotification()
        val normalLaunch = Intent(Intent.ACTION_MAIN)

        deliverIntent(activity, normalLaunch)

        assertSame(normalLaunch, activity.intent)
        assertFalse(activity.intent.hasExtra("payload"))
    }

    @Test
    fun notificationClickReplacesPreviousNotificationLaunch() {
        val activity = activityWithPreviousNotification()
        val notificationClick = Intent("SELECT_NOTIFICATION")
            .putExtra("notificationId", 456)
            .putExtra("payload", "series_add_series-2")

        deliverIntent(activity, notificationClick)

        assertSame(notificationClick, activity.intent)
        assertEquals(456, activity.intent.getIntExtra("notificationId", 0))
        assertEquals("series_add_series-2", activity.intent.getStringExtra("payload"))
    }

    private fun activityWithPreviousNotification(): MainActivity {
        // No onCreate: these tests exercise intent delivery before Flutter/Dart
        // initialization, without starting a native Flutter engine.
        return Robolectric.buildActivity(MainActivity::class.java).get().apply {
            intent = Intent("SELECT_NOTIFICATION")
                .putExtra("notificationId", 123)
                .putExtra("payload", "series_add_series-1")
        }
    }

    private fun deliverIntent(activity: MainActivity, intent: Intent) {
        FlutterActivity::class.java.getDeclaredMethod("onNewIntent", Intent::class.java).apply {
            isAccessible = true
        }.invoke(activity, intent)
    }
}

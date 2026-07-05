package de.exploratia.xtracker

import android.os.Bundle
import androidx.annotation.Keep
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        keepQuickActionDrawables()
    }

    @Keep
    private fun keepQuickActionDrawables() {
        val quickActionDrawableIds = intArrayOf(
            R.drawable.qa_open_url,
            R.drawable.qa_series_add_00,
            R.drawable.qa_series_add_01,
            R.drawable.qa_series_add_02,
            R.drawable.qa_series_add_03,
            R.drawable.qa_series_add_04,
            R.drawable.qa_series_add_05,
            R.drawable.qa_series_add_06,
            R.drawable.qa_series_add_07,
            R.drawable.qa_series_add_08,
            R.drawable.qa_series_add_09,
            R.drawable.qa_series_add_10,
            R.drawable.qa_series_add_11,
        )

        // Touch resource entry names so the shrinker treats them as reachable.
        for (drawableId in quickActionDrawableIds) {
            resources.getResourceEntryName(drawableId)
        }
    }
}

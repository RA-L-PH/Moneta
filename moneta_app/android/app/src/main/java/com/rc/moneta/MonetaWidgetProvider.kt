package com.rc.moneta

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class MonetaWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.moneta_widget)
            val prefs = HomeWidgetPlugin.getData(context)
            val debit = prefs.getString("today_debit", "0.00")
            val credit = prefs.getString("today_credit", "0.00")
            views.setTextViewText(R.id.tvDebit, "Spent: $debit")
            views.setTextViewText(R.id.tvCredit, "Income: $credit")
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

package com.rc.moneta

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import io.flutter.plugin.common.EventChannel

class SmsReceiver: BroadcastReceiver() {
    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            val msgs = Telephony.Sms.Intents.getMessagesFromIntent(intent)
            val builder = StringBuilder()
            for (msg in msgs) {
                builder.append("${msg.displayOriginatingAddress}: ${msg.displayMessageBody}\n")
            }
            eventSink?.success(builder.toString())
        }
    }
}

package com.rc.moneta

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		EventChannel(flutterEngine.dartExecutor.binaryMessenger, "moneta/sms_stream").setStreamHandler(
			object : EventChannel.StreamHandler {
				override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
					SmsReceiver.eventSink = events
				}

				override fun onCancel(arguments: Any?) {
					SmsReceiver.eventSink = null
				}
			}
		)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "moneta/sms_inbox")
			.setMethodCallHandler { call, result ->
				if (call.method == "readInbox") {
					result.success(readInbox())
				} else {
					result.notImplemented()
				}
			}
	}

	private fun readInbox(): List<Map<String, String>> {
		val list = mutableListOf<Map<String, String>>()
		val cr = contentResolver
		val uri = android.net.Uri.parse("content://sms/inbox")
		val cursor = cr.query(uri, arrayOf("address", "body", "date"), null, null, "date DESC")
		cursor?.use { c ->
			val addressIdx = c.getColumnIndex("address")
			val bodyIdx = c.getColumnIndex("body")
			val dateIdx = c.getColumnIndex("date")
			var count = 0
			while (c.moveToNext() && count < 200) {
				val m = mapOf(
					"address" to (c.getString(addressIdx) ?: ""),
					"body" to (c.getString(bodyIdx) ?: ""),
					"date" to (c.getLong(dateIdx).toString())
				)
				list.add(m)
				count++
			}
		}
		return list
	}
}

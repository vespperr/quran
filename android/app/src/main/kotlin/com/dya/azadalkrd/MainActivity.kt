package com.dya.azadalkrd

import android.content.Intent
import android.graphics.Bitmap
import android.graphics.pdf.PdfRenderer
import android.net.Uri
import android.os.Build
import android.os.ParcelFileDescriptor
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File

class MainActivity: FlutterActivity() {
    private val channel = "com.dya.azadalkrd/move_to_background"
    private val prayerChannel = "com.dya.azadalkrd/prayer_alarms"
    private val pdfViewerChannel = "com.dya.azadalkrd/pdf_viewer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "moveTaskToBack" -> {
                    @Suppress("DEPRECATION")
                    val moved = moveTaskToBack(false)
                    result.success(moved)
                }
                "openExactAlarmSettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            startActivity(Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                                data = Uri.parse("package:$packageName")
                            })
                            result.success(true)
                        } catch (e: Exception) {
                            result.success(false)
                        }
                    } else {
                        result.success(false)
                    }
                }
                "openBatteryOptimizationSettings" -> {
                    try {
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                            data = Uri.parse("package:$packageName")
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, prayerChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAdhanOptions" -> {
                    result.success(AdhanOptions.toMapList())
                }
                "playAdhan" -> {
                    val rawName = call.argument<String>("rawName")
                    AdhanPlayer.play(this, rawName)
                    result.success(null)
                }
                "stopAdhan" -> {
                    AdhanPlayer.stop()
                    result.success(null)
                }
                "schedulePrayerAlarms" -> {
                    try {
                        @Suppress("UNCHECKED_CAST")
                        val list = call.argument<List<Map<String, Any>>>("alarms") ?: emptyList()
                        val adhanRaw = call.argument<String>("adhanRawName")
                        val adhanDurationMs = call.argument<Int>("adhanDurationMs") ?: 3000
                        val displayTimes = call.argument<String>("displayTimes")
                        val widgetCity = call.argument<String>("widgetCity")
                        val items = list.map { map ->
                            PrayerAlarmScheduler.AlarmItem(
                                id = (map["id"] as? Number)?.toInt() ?: 0,
                                triggerAtMillis = (map["triggerAtMillis"] as? Number)?.toLong() ?: 0L,
                                title = map["title"] as? String ?: "",
                                body = map["body"] as? String ?: "",
                                prayerName = map["prayerName"] as? String ?: ""
                            )
                        }
                        PrayerAlarmScheduler.scheduleAlarms(this, items, adhanRaw, adhanDurationMs, displayTimes, widgetCity)
                        PrayerTimesWidgetProvider.updateAllWidgets(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "cancelPrayerAlarms" -> {
                    try {
                        PrayerAlarmScheduler.cancelAll(this)
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, pdfViewerChannel).setMethodCallHandler { call, result ->
            when (call.method) {
                "openPdf" -> {
                    val path = call.argument<String>("path")
                    val title = call.argument<String>("title") ?: "PDF"
                    if (path.isNullOrBlank() || !isPdfPathAllowed(path)) {
                        result.error("INVALID_PATH", "PDF path must be under app cache or files dir", null)
                        return@setMethodCallHandler
                    }
                    try {
                        startActivity(
                            Intent(this, PdfViewerActivity::class.java).apply {
                                putExtra(PdfViewerActivity.EXTRA_PATH, path)
                                putExtra(PdfViewerActivity.EXTRA_TITLE, title)
                            },
                        )
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("OPEN_FAILED", e.message, null)
                    }
                }
                "getPdfThumbnail" -> {
                    val path = call.argument<String>("path")
                    val maxWArg = call.argument<Number>("maxWidth")
                    val maxW = maxWArg?.toInt()?.coerceIn(64, 1024) ?: 480
                    if (path.isNullOrBlank() || !isPdfPathAllowed(path)) {
                        result.error("INVALID_PATH", "PDF path must be under app cache or files dir", null)
                        return@setMethodCallHandler
                    }
                    var pfd: ParcelFileDescriptor? = null
                    var renderer: PdfRenderer? = null
                    try {
                        val file = File(path)
                        pfd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
                        renderer = PdfRenderer(pfd)
                        if (renderer.pageCount < 1) {
                            result.success(null)
                            return@setMethodCallHandler
                        }
                        val page = renderer.openPage(0)
                        try {
                            val iw = page.width
                            val ih = page.height
                            if (iw <= 0 || ih <= 0) {
                                result.success(null)
                                return@setMethodCallHandler
                            }
                            val scale = if (iw > maxW) maxW.toFloat() / iw else 1f
                            val w = (iw * scale).toInt().coerceAtLeast(1)
                            val h = (ih * scale).toInt().coerceAtLeast(1)
                            val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
                            page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY)
                            val stream = ByteArrayOutputStream()
                            bitmap.compress(Bitmap.CompressFormat.PNG, 92, stream)
                            bitmap.recycle()
                            result.success(stream.toByteArray())
                        } finally {
                            page.close()
                        }
                    } catch (e: Exception) {
                        result.error("THUMB_FAIL", e.message, null)
                    } finally {
                        try {
                            renderer?.close()
                        } catch (_: Exception) {
                        }
                        try {
                            pfd?.close()
                        } catch (_: Exception) {
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isPdfPathAllowed(path: String): Boolean {
        return try {
            val canon = File(path).canonicalPath
            val cache = cacheDir.canonicalPath
            val files = filesDir.canonicalPath
            canon.startsWith(cache) || canon.startsWith(files)
        } catch (_: Exception) {
            false
        }
    }
}

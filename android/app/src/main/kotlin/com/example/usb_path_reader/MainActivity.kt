package com.example.usb_path_reader

import android.content.Context
import android.os.Build
import android.os.Environment
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "usb_path_reader/usb"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getUsbPath") {
                val usbPath = getUsbPath()
                if (usbPath != null) {
                    result.success(usbPath)
                } else {
                    result.error("UNAVAILABLE", "USB Path not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getUsbPath(): String? {
        val storageVolumes = getSystemService(Context.STORAGE_SERVICE) as android.os.storage.StorageManager
        val storageVolumeList = storageVolumes.storageVolumes
        for (volume in storageVolumeList) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                if (volume.isRemovable) {
                    val uuid = volume.uuid
                    if (uuid != null) {
                        return "/storage/$uuid"
                    }
                }
            }
        }
        return null
    }
}

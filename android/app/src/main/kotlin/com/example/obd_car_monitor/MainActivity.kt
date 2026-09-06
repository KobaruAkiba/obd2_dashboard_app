package com.example.obd_car_monitor

import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Native Bluetooth bridge stub.
 * Real SPP/BLE connection will be wired here when hardware support lands.
 */
class MainActivity : FlutterActivity() {

    private val channelName = "obd_bluetooth/android"
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var receiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "discover_devices" -> discoverDevices(result)
                    "connect" -> connectToDevice(call, result)
                    "disconnect" -> {
                        disconnect()
                        result.success(null)
                    }
                    "enable_streaming" -> {
                        result.success(true)
                    }
                    "is_bluetooth_enabled" -> isBluetoothEnabled(result)
                    "check_permissions" -> result.success(true)
                    "get_connection_status" -> result.success(false)
                    else -> result.notImplemented()
                }
            }
    }

    private fun discoverDevices(result: MethodChannel.Result) {
        result.success(emptyList<Map<String, Any?>>())
    }

    private fun connectToDevice(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as? Map<*, *>
        val macAddress = arguments?.get("mac") as? String
        if (macAddress == null) {
            result.error("NULL_MAC", "MAC address is required", null)
            return
        }
        // Stub: report success so Flutter can continue with simulated stream.
        result.success(true)
    }

    private fun disconnect() {
        // No active native session yet.
    }

    private fun isBluetoothEnabled(result: MethodChannel.Result) {
        val adapter = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            bluetoothAdapter
        } else {
            @Suppress("DEPRECATION")
            BluetoothAdapter.getDefaultAdapter()
        }
        result.success(adapter?.isEnabled == true)
    }

    override fun onDestroy() {
        super.onDestroy()
        disconnect()
        receiver?.let {
            unregisterReceiver(it)
            receiver = null
        }
    }
}

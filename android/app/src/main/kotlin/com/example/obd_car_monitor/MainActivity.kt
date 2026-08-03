package com.example.obd_car_monitor

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    
    private val CHANNEL = "obd_bluetooth/android"
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var receiver: BroadcastReceiver? = null
    
    @Override
    fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Create method channel for Flutter to Android communication
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "discover_devices" -> {
                    discoverDevices(result)
                }
                "connect" -> {
                    connectToDevice(call, result)
                }
                "disconnect" -> {
                    disconnect()
                    result.success(null)
                }
                "enable_streaming" -> {
                    enableStreaming()
                    result.success(true)
                }
                "is_bluetooth_enabled" -> {
                    isBluetoothEnabled(result)
                }
                "check_permissions" -> {
                    checkPermissions(result)
                }
                "get_connection_status" -> {
                    getConnectionStatus(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun enableStreaming() {
        // Start foreground service if needed
        // Enable Bluetooth data streaming from adapter
    }
    
    private fun discoverDevices(result: MethodChannel.Result) {
        try {
            val devices = getDiscoverableDevices().toList()
            result.success(devices)
        } catch (e: Exception) {
            result.error("DISCOVERY_ERROR", e.message, null)
        }
    }
    
    private fun connectToDevice(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as? Map<String, Any> ?: return
        
        val macAddress = arguments["mac"] as? String
        val serviceUuid = arguments["serviceUuid"] as? String
        val baudRate = arguments["baudRate"] as? Int
        
        if (macAddress == null) {
            result.error("NULL_MAC", "MAC address is required", null)
            return
        }
        
        try {
            // Parse and connect to Bluetooth device
            // Implementation depends on available Bluetooth Serial library
            
            // Example: Connect using bluetooth_serial_plus logic
            // This would be implemented in native Java/Kotlin code
            val connectionSuccess = true // Simulated for now
            
            if (connectionSuccess) {
                result.success(true)
            } else {
                result.error("CONNECTION_ERROR", "Failed to connect to device", null)
            }
        } catch (e: Exception) {
            result.error("CONNECTION_ERROR", e.message, null)
        }
    }
    
    private fun disconnect() {
        try {
            // Close Bluetooth Serial connection
            bluetoothAdapter?.close()
        } catch (e: Exception) {
            println("Disconnect error: ${e.message}")
        }
    }
    
    private fun isBluetoothEnabled(result: MethodChannel.Result) {
        val enabled = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            bluetoothAdapter?.isEnabled != null && bluetoothAdapter?.isEnabled!!
        } else {
            @Suppress("DEPRECATION")
            BluetoothAdapter.getDefaultAdapter() != null &&
                    BluetoothAdapter.getDefaultAdapter()?.isEnabled ?: false
        }
        
        result.success(enabled)
    }
    
    private fun checkPermissions(result: MethodChannel.Result) {
        val granted = true // Simulated - actual implementation requires checking permissions
        
        if (granted) {
            result.success(true)
        } else {
            result.error("PERMISSION_DENIED", "Bluetooth permissions not granted", null)
        }
    }
    
    private fun getConnectionStatus(result: MethodChannel.Result) {
        val connected = false // Simulated
        
        result.success(connected)
    }
    
    private fun getDiscoverableDevices(): List<Map<String, Any?>> {
        return listOf() // Actual implementation would query paired devices
    }
    
    override fun onDestroy() {
        super.onDestroy()
        disconnect()
        
        // Unregister receiver to prevent memory leaks
        if (receiver != null) {
            unregisterReceiver(receiver)
            receiver = null
        }
    }
    
    companion object {
        const val BLUETOOTH_STATE_CHANGE_ACTION = "android.bluetooth.adapter.action.STATE_CHANGED"
    }
}


package com.example.flutterauth

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import android.os.BatteryManager
import android.content.ContextWrapper
import android.content.IntentFilter
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.content.Context
import android.content.Intent

import android.os.Bundle
import android.os.Build

import androidx.core.app.NotificationCompat
import android.content.ContentResolver
import android.content.res.AssetManager
import android.media.AudioAttributes
import android.net.Uri
import android.app.NotificationChannel
import android.app.NotificationManager



class MainActivity: FlutterActivity() {
    companion object{
        private val CHANNEL = "com.trace.service"
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine){
        // GeneratedPluginRegistrant.registerWith(flutterEngine)
        super.configureFlutterEngine(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler{call, result ->
            if(call.method == "getBatteryLevel"){
                val batteryLevel = getBatteryLevel()
                if(batteryLevel != -1){
                    result.success(batteryLevel)
                } else {
                    result.error("Tidak ditemukan","Battery level tidak dapat diakses", null);
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?){
        super.onCreate(savedInstanceState)
        createNotificationChannelTrace()
        actionOnService(Actions.START)
    }

    private fun actionOnService(action: Actions){
        Intent(this, MainService::class.java).also{
            it.action = action.name
            if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
                log("start service on version code O")
                startForegroundService(it)
                return
            }

            log("start service under version code O")
            startService(it)
        }
    }

    private fun getBatteryLevel():Int{
        val batteryLevel: Int
        if(VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP){
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        return batteryLevel
    }

    private fun createNotificationChannelTrace(){
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Create the NotificationChannel
            val name = "Service Background"
            val descriptionText = "Running service in background every time"
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val mChannel = NotificationChannel("trace_notif", name, importance)
            mChannel.description = descriptionText
            mChannel.setShowBadge(false)
            val soundUri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://"+ getApplicationContext().getPackageName() + "/" + R.raw.smstone)
            val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .build()
            mChannel.setSound(soundUri, audioAttributes)
            
            val notificationManager = getSystemService(NotificationManager::class.java) as NotificationManager
            notificationManager.createNotificationChannel(mChannel)
        }
    }
}

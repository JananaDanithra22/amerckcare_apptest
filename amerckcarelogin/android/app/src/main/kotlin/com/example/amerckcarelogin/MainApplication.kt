package com.example.amerckcarelogin

import android.app.Application
import com.facebook.FacebookSdk
import com.facebook.appevents.AppEventsLogger

class MainApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // Initialize Facebook SDK early in the app lifecycle
        FacebookSdk.sdkInitialize(applicationContext)
        // Optional: enable App Events logging for debugging in Facebook dashboard/tools
        AppEventsLogger.activateApp(this)
    }
}

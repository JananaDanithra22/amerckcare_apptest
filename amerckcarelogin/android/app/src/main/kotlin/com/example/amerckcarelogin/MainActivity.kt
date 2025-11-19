package com.example.amerckcarelogin

import io.flutter.embedding.android.FlutterFragmentActivity
import android.content.pm.PackageManager
import android.content.pm.PackageInfo
import android.os.Bundle
import android.util.Base64
import android.util.Log
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        printKeyHash()
    }

    private fun printKeyHash() {
        try {
            val info: PackageInfo = packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_SIGNATURES
            )
            info.signatures?.forEach { signature ->
                val md = MessageDigest.getInstance("SHA")
                md.update(signature.toByteArray())
                val keyHash = Base64.encodeToString(md.digest(), Base64.NO_WRAP)
                Log.d("KeyHash", "🔑 Facebook Key Hash: $keyHash")
            }
        } catch (e: PackageManager.NameNotFoundException) {
            Log.e("KeyHash", "Package not found: ${e.message}")
        } catch (e: NoSuchAlgorithmException) {
            Log.e("KeyHash", "Algorithm not found: ${e.message}")
        }
    }
}

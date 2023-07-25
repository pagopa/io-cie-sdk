package it.ipzs.cieidsdk.native_bridge

import com.facebook.react.bridge.*
import it.ipzs.cieidsdk.common.Callback
import it.ipzs.cieidsdk.common.CieIDSdk
import com.facebook.react.modules.core.RCTNativeAppEventEmitter
import com.facebook.react.bridge.Arguments.createMap
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.NativeModule.NativeMethod
import it.ipzs.cieidsdk.event.Event
import android.content.Intent
import android.app.Activity
import android.net.Uri

class CieModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext),
    Callback {


    private var ciePinAttemptsLeft: Int = 0

    /**
     * onSuccess is called when the CIE authentication is successfully completed.
     * @param[url] the form consent url
     */
    override fun onSuccess(url: String) {
        this.sendEvent(successChannel, url)
    }

    /**
     * onError is called if some errors occurred during CIE authentication
     * @param[error] the error occurred
     */
    override fun onError(error: Throwable) {
        this.sendEvent(errorChannel, error.message ?: "generic error")
    }

    /**
     * onEvent is called if an event occurs
     */
    override fun onEvent(event: Event) {
        ciePinAttemptsLeft = event.attemptsLeft ?: ciePinAttemptsLeft
        this.sendEvent(eventChannel,event.event.toString())
    }

    override fun getName(): String {
        return "NativeCieModule"
    }

    private fun getWritableMap(eventValue: String): WritableMap {
        val writableMap = createMap()
        writableMap.putString("event", eventValue)
        writableMap.putInt("attemptsLeft", ciePinAttemptsLeft)
        return writableMap
    }

    private fun sendEvent(channel: String, eventValue: String) {
        reactApplicationContext
            .getJSModule(RCTNativeAppEventEmitter::class.java)
            .emit(channel, getWritableMap(eventValue))
    }


    @ReactMethod
    fun start(callback: com.facebook.react.bridge.Callback) {
        try {
            CieIDSdk.start(getCurrentActivity()!!, this)
            callback.invoke()
        } catch (e: RuntimeException) {
            callback.invoke(e.message)
        }
    }

    @ReactMethod
    fun isNFCEnabled(callback: com.facebook.react.bridge.Callback) {

        callback.invoke(CieIDSdk.isNFCEnabled(reactApplicationContext))
    }

    @ReactMethod
    fun hasNFCFeature(callback: com.facebook.react.bridge.Callback) {
        callback.invoke(CieIDSdk.hasFeatureNFC(reactApplicationContext))
    }

    @ReactMethod
    fun setPin(pin: String, callback: com.facebook.react.bridge.Callback) {
        try {
            CieIDSdk.pin = pin
            callback.invoke()
        } catch (e: IllegalArgumentException) {
            callback.invoke(e.message)
        }
    }

    @ReactMethod
    fun setAuthenticationUrl(url: String) {
        CieIDSdk.setUrl(url)
    }

    @ReactMethod
    fun enableLog(isEnabled: Boolean) {
        CieIDSdk.enableLog(isEnabled)
    }

    @ReactMethod
    fun setCustomIdpUrl(
        idpUrl: String?
    ) {
        CieIDSdk.setCustomIdpUrl(idpUrl)
    }

    @ReactMethod
    fun startListeningNFC(callback: com.facebook.react.bridge.Callback) {
        try {
            CieIDSdk.startNFCListening(getCurrentActivity()!!)
            callback.invoke()
        } catch (e: RuntimeException) {
            callback.invoke(e.message)
        }
    }

    @ReactMethod
    fun stopListeningNFC(callback: com.facebook.react.bridge.Callback) {
        try {
            CieIDSdk.stopNFCListening(getCurrentActivity()!!)
            callback.invoke()
        } catch (e: RuntimeException) {
            callback.invoke(e.message)
        }
    }

    companion object {
        const val eventChannel: String = "onEvent"
        const val errorChannel: String = "onError"
        const val successChannel: String = "onSuccess"
    }

    @ReactMethod
    fun openNFCSettings(callback: com.facebook.react.bridge.Callback) {
        val currentActivity = getCurrentActivity()!!
        if (currentActivity == null) {
            callback.invoke("fail to get current activity");
        } else {
            CieIDSdk.openNFCSettings(currentActivity)
            callback.invoke()
        }
    }

    @ReactMethod
    fun hasApiLevelSupport(callback: com.facebook.react.bridge.Callback) {
        callback.invoke(CieIDSdk.hasApiLevelSupport())
    }

    @ReactMethod
    fun launchCieID(callback: com.facebook.react.bridge.Callback) {
        val currentActivity = getCurrentActivity()!!
        if (currentActivity == null) {
            callback.invoke("fail to get current activity")
        } else {
            this.launchCieID(currentActivity)
            callback.invoke()
        }
    }

    /**
     * Open CieID application
     * Use this method when receive CieIDEvent.Card.ON_CARD_PIN_LOCKED. User needs to unlock CIE after 3 pin error.
     */
    fun launchCieID(activity: Activity){
        val cieIdPackage = "it.ipzs.cieid"
        val launchIntent = activity.getPackageManager().getLaunchIntentForPackage(cieIdPackage);
        if(launchIntent == null){
            activity.startActivity(Intent(Intent.ACTION_VIEW).setData(Uri.parse("https://play.google.com/store/apps/details?id=$cieIdPackage")))
        }
        else{
           activity.startActivity(launchIntent) 
        }
    }

}

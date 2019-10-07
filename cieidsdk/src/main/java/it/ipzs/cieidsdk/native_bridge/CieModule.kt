
package it.ipzs.cieidsdk.native_bridge

import com.facebook.react.bridge.*
import it.ipzs.cieidsdk.common.Callback
import it.ipzs.cieidsdk.common.CieIDSdk
import it.ipzs.cieidsdk.common.Event
import com.facebook.react.modules.core.RCTNativeAppEventEmitter
import com.facebook.react.bridge.Arguments.createMap
import java.util.*


class CieModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext), Callback {


    private var cieInvalidPinAttempts : Int = 0

    /**
     * Callback method that return the access url when the tag nfc is correctly decripted
     */
    override fun onSuccess(url: String) {
        this.sendEvent(successChannel, url)
    }

    /**
     * Callback method that returns any errors during the decript phase
     */
    override fun onError(e: Throwable) {
        this.sendEvent(errorChannel, e.message ?: "generic error")
    }

    /**
     * Callback method that returns an enum describing the steps of decryption
     */
    override fun onEvent(event: Event) {
        cieInvalidPinAttempts = event.attempts;
        this.sendEvent(eventChannel,event.toString())
    }

    override fun getName(): String {
        return "NativeCieModule"
    }

    private fun getWritableMap(eventValue: String) : WritableMap{
        val writableMap = createMap()
        writableMap.putString("event", eventValue)
        writableMap.putInt("attempts", cieInvalidPinAttempts)
        return writableMap
    }

    private fun sendEvent(channel : String, eventValue : String)
     {
        reactApplicationContext
            .getJSModule(RCTNativeAppEventEmitter::class.java)
            .emit(channel, getWritableMap(eventValue))
    }


    @ReactMethod
    fun start(callback: com.facebook.react.bridge.Callback){
        try {
            CieIDSdk.start(getCurrentActivity()!!, this)
            callback.invoke(null, null)
            cieInvalidPinAttempts = 0;
        } catch (e: RuntimeException) {
            callback.invoke(e.message,null)
        }
    }

    @ReactMethod
    fun isNFCEnabled(callback: com.facebook.react.bridge.Callback) {
        callback.invoke(CieIDSdk.isNFCEnabled(getCurrentActivity()!!))
    }

    @ReactMethod
    fun hasNFCFeature(callback: com.facebook.react.bridge.Callback) {
        callback.invoke(CieIDSdk.hasFeatureNFC(getCurrentActivity()!!))
    }

    @ReactMethod
    fun setPin(pin: String) {
        CieIDSdk.pin = pin
    }

    @ReactMethod
    fun setAuthenticationUrl(url: String) {
        CieIDSdk.setUrl(url)
    }

    @ReactMethod
    fun startListeningNFC(callback: com.facebook.react.bridge.Callback) {
        try {
            CieIDSdk.startNFCListening(getCurrentActivity()!!)
            callback.invoke(null,null)
        } catch (e: RuntimeException) {
            callback.invoke(e.message,null)
        }
    }

    @ReactMethod
    fun stopListeningNFC(callback: com.facebook.react.bridge.Callback) {
        try {
            CieIDSdk.stopNFCListening(getCurrentActivity()!!)
            callback.invoke(null, null)
        } catch (e: RuntimeException) {
            callback.invoke(e.message,null)
        }
    }

    companion object {
        const val eventChannel: String = "onEvent"
        const val errorChannel: String = "onError"
        const val successChannel: String = "onSuccess"
    }

}

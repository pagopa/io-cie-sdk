"use strict";
import { NativeEventEmitter, NativeModules, Platform } from "react-native";

const NativeCie = NativeModules.NativeCieModule;
const NativeCieEmitter = new NativeEventEmitter(NativeCie);

class CieManager {
  constructor() {
    this._eventHandlerSuccess=[];
    this._eventHandlerError=[];
    this._eventHandlerEvent=[];
    this._registerEventEmitter();
  }

  /**
   * private
   */
  _registerEventEmitter = () => {
    NativeCieEmitter.addListener("onEvent", e => {
      this._eventHandlerEvent.forEach(h => h(e));
    });
    NativeCieEmitter.addListener("onSuccess", e => {
          this._eventHandlerSuccess.forEach(h => h(e));
    });
    NativeCieEmitter.addListener("onError", e => {
          this._eventHandlerError.forEach(h => h(e));
    });
  };

  setEventListener = listner => {
    if (this._eventHandlerEvent.indexOf(listner) >= 0) {
      return;
    }
    this._eventHandlerEvent = [...this._eventHandlerEvent, listner];
  };

  setErrorListener = listner => {
    if (this._eventHandlerError.indexOf(listner) >= 0) {
      return;
    }
    this._eventHandlerError = [...this._eventHandlerError, listner];
   };

  setSuccessListener = listner => {
    if (this._eventHandlerSuccess.indexOf(listner) >= 0) {
      return;
    }
     this._eventHandlerSuccess = [...this._eventHandlerSuccess, listner];
   };

  setPin = pin => {
    NativeCie.setPin(pin);
  };

  setAuthenticationUrl = url => {
    NativeCie.setAuthenticationUrl(url);
  };

  start = () => {
    return new Promise((resolve, reject) => {
      NativeCie.start((err, _) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  };

  startListeningNFC = () => {
    return new Promise((resolve, reject) => {
      NativeCie.startListeningNFC((err, _) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  };

  stopListeningNFC = () => {
    return new Promise((resolve, reject) => {
      NativeCie.stopListeningNFC((err, _) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  };

  /**
   * Return true if the nfc is enabled, on the device in Settings screen
   * is possible enable or disable it.
   */
  isNFCEnabled = () => {
    if (Platform.OS === "ios") {
      return Promise.reject("not implemented");
    }
    return new Promise(resolve => {
      NativeCie.isNFCEnabled((result) => {
          resolve(result);
      });
    });
  };

  /**
   * Check if the hardware module nfc is installed (only for Android devices)
   */
  hasNFCFeature = () => {
    if (Platform.OS === "ios") {
      return Promise.reject("not implemented");
    }
    return new Promise(resolve => {
      NativeCie.hasNFCFeature((result) => {
          resolve(result);
      });
    });
  };
}

export default new CieManager();

"use strict";
import { NativeEventEmitter, NativeModules, Platform } from "react-native";

const NativeCie = NativeModules.NativeCieModule;
const NativeCieEmitter = new NativeEventEmitter(NativeCie);

class CieManager {
  constructor() {
    this._eventSuccessHandler=[];
    this._eventErrorHandler=[];
    this._eventHandler=[];
    this._registerEventEmitter();
    this._subSuccess;
    this._subError;
    this._subEvent;
  }

  /**
   * private
   */
  _registerEventEmitter = () => {
      this._subEvent =NativeCieEmitter.addListener("onEvent", e => {
          this._eventHandler.forEach(h => h(e));
    });
      this._subSuccess = NativeCieEmitter.addListener("onSuccess", e => {
          this._eventSuccessHandler.forEach(h => h(e));
    });
      this._subError = NativeCieEmitter.addListener("onError", e => {
          this._eventErrorHandler.forEach(h => h(e));
    });
  };

  onEvent = listner => {
    if (this._eventHandler.indexOf(listner) >= 0) {
      return;
    }
    this._eventHandler = [...this._eventHandler, listner];
  };

  onError = listner => {
    if (this._eventErrorHandler.indexOf(listner) >= 0) {
      return;
    }
    this._eventErrorHandler = [...this._eventErrorHandler, listner];
  };

  onSuccess = listner => {
    if (this._eventSuccessHandler.indexOf(listner) >= 0) {
      return;
    }
     this._eventSuccessHandler = [...this._eventSuccessHandler, listner];
  };

  removeAllListeners = () => {
    this._subError.remove();
    this._subEvent.remove();
    this._subSuccess.remove();
  }

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
          resolve(true);
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
          resolve(true);
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
          resolve(true);
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

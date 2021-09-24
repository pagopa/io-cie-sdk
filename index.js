"use strict";
import { NativeEventEmitter, NativeModules, Platform } from "react-native";

const NativeCie = Platform.OS === "ios" ? NativeModules.CieModule : NativeModules.NativeCieModule;

const isIosDeviceCompatible = NativeCie !== null && Platform.OS === "ios" && parseInt(Platform.Version, 10) >= 13;

class CieManager {
  constructor() {
    this._eventSuccessHandlers = [];
    this._eventErrorHandlers = [];
    this._eventHandlers = [];
    this._registerEventEmitter();
  }

  /**
   * private
   */
  _registerEventEmitter = () => {
    if (Platform.OS === "ios" && !isIosDeviceCompatible) {
      return;
    }
    const NativeCieEmitter = new NativeEventEmitter(NativeCie);
    NativeCieEmitter.addListener("onEvent", e => {
      this._eventHandlers.forEach(h => h(e));
    });
    NativeCieEmitter.addListener("onSuccess", e => {
      this._eventSuccessHandlers.forEach(h => h(e.event));
    });
    NativeCieEmitter.addListener("onError", e => {
      this._eventErrorHandlers.forEach(h => h(new Error(e.event)));
    });
  };

  onEvent = listner => {
    if (this._eventHandlers.indexOf(listner) >= 0) {
      return;
    }
    this._eventHandlers = [...this._eventHandlers, listner];
  };

  onError = listner => {
    if (this._eventErrorHandlers.indexOf(listner) >= 0) {
      return;
    }
    this._eventErrorHandlers = [...this._eventErrorHandlers, listner];
  };

  onSuccess = listner => {
    if (this._eventSuccessHandlers.indexOf(listner) >= 0) {
      return;
    }
    this._eventSuccessHandlers = [...this._eventSuccessHandlers, listner];
  };

  removeAllListeners = () => {
    this._eventSuccessHandlers.length = 0;
    this._eventErrorHandlers.length = 0;
    this._eventHandlers.length = 0;
  };

  /**
   * set the CIE pin. If the format doesn't respect a 8 length string of digits
   * the promise will be rejected
   */
  setPin = pin => {
    if (Platform.OS === "ios") {
      return new Promise((resolve, reject) => {
        if(!isIosDeviceCompatible){
          reject("this device is not compatible");
          return;
        }
        NativeCie.setPin(pin);
        resolve();
        });
      }
    return new Promise((resolve, reject) => {
      NativeCie.setPin(pin, err => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  };

  setAlertMessage = (key, value) => {
    if (Platform.OS === "ios") {
      if(!isIosDeviceCompatible){
        return;
      }
      NativeCie.setAlertMessage(key, value);
    }
  }

  setAuthenticationUrl = url => {
    if (Platform.OS === "ios") {
        if(!isIosDeviceCompatible){
            return;
        }
        NativeCie.setAuthenticationUrl(url);
        return;
      }
    NativeCie.setAuthenticationUrl(url);
  };

  start = () => {
    if (Platform.OS === "ios") {
        if(!isIosDeviceCompatible){
            return Promise.reject("not compatibile");
        }
    }
    return new Promise((resolve, reject) => {
      NativeCie.start(err => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  };

  startListeningNFC = () => {
    if (Platform.OS === "ios") {
        if(isIosDeviceCompatible){
            return Promise.resolve()
        }
      return Promise.reject("not implemented");
    }
    return new Promise((resolve, reject) => {
      NativeCie.startListeningNFC(err => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  };

  stopListeningNFC = () => {
    if (Platform.OS === "ios") {
      // do nothing
      return Promise.resolve();
    }
    return new Promise((resolve, reject) => {
      NativeCie.stopListeningNFC(err => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  };

  isCIEAuthenticationSupported = async () => {
    try {
      const hasNFCFeature = await this.hasNFCFeature();
      const hasApiLevelSupport = await this.hasApiLevelSupport();
      return Promise.resolve(hasNFCFeature && hasApiLevelSupport);
    } catch {
      return Promise.resolve(false);
    }
  };

  /**
   * Return true if the nfc is enabled, on the device in Settings screen
   * is possible enable or disable it.
   */
  isNFCEnabled = () => {
    return new Promise(resolve => {
      NativeCie.isNFCEnabled(result => {
        resolve(result);
      });
    });
  };

  /**
    return a Promise will be resolved with true if the current OS supports the authentication. 
    This method is due because with API level < 23 a security exception is raised
    read more here - https://github.com/teamdigitale/io-cie-android-sdk/issues/10
   */
  hasApiLevelSupport = () => {
    if (Platform.OS === "ios") {
        return Promise.resolve(isIosDeviceCompatible);
      }
    return new Promise(resolve => {
      NativeCie.hasApiLevelSupport(result => {
        resolve(result);
      });
    });
  };

  /**
   * Check if the hardware module nfc is installed (only for Android devices)
   */
  hasNFCFeature = () => {
    return new Promise(resolve => {
      NativeCie.hasNFCFeature(result => {
        resolve(result);
      });
    });
  };

  /**
   * It opens OS Settings on NFC section
   *
   */
  openNFCSettings = () => {
    if (Platform.OS === "ios") {
      return Promise.reject("not implemented");
    }
    return new Promise((resolve, reject) => {
      NativeCie.openNFCSettings(err => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  };

  launchCieID = () => {
    if (Platform.OS === "ios") {
      return Promise.reject("not implemented");
    }
    return new Promise((resolve, reject) => {
      NativeCie.launchCieID(err => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  };
}

export default new CieManager();

// Type definitions for react-native-cie
// Project: https://github.com/teamdigitale/io-cie-android-sdk
declare module "react-native-cie" {

  // All events returned by onEvent callback
  export type CIEEvent = 'ON_TAG_DISCOVERED_NOT_CIE' | 'ON_TAG_DISCOVERED' | 'ON_TAG_LOST' |
  'ON_CARD_PIN_LOCKED' | 'ON_PIN_ERROR' | 'CERTIFICATE_EXPIRED' | 'CERTIFICATE_REVOKED' |
  'AUTHENTICATION_ERROR' | 'ON_NO_INTERNET_CONNECTION';

  interface CieManager {
    isNFCEnabled(): Promise<boolean>;
    hasNFCFeature(): Promise<boolean>;
    setPin(pin: string): void;
    // Set a listener on all possible CIEEEvent (see above)
    // during reading and decoding of the nfc tag
    onEvent(callback: (event: CIEEvent) => void): void;
    // Set a listener if an error should occur so as to handle it
    onError(callback: (errorMessage: string) => void): void;
    // Set a listener to know when the decoding process is finished and we have an access url
    onSuccess(callback: (url: string) => void): void;
    setAuthenticationUrl(url: string): void;
    start(): Promise<void>;
    startListeningNFC(): Promise<void>;
    stopListeningNFC(): Promise<void>;
    // Call this void to remove all listeners when the authentication phase is finished
    removeAllListeners(): void;
  }

  const cieManager: CieManager;
}

export default cieManager;

// Type definitions for react-native-cie
// Project: https://github.com/teamdigitale/io-cie-android-sdk
declare module "react-native-cie" {

  // All events returned by onEvent callback
  export type CIEEvent = 'ON_TAG_DISCOVERED_NOT_CIE' | 'ON_TAG_DISCOVERED' | 'ON_TAG_LOST' |
  'ON_CARD_PIN_LOCKED' | 'ON_PIN_ERROR'  | 'PIN_INPUT_ERROR' | 'CERTIFICATE_EXPIRED' | 'CERTIFICATE_REVOKED' |
  'AUTHENTICATION_ERROR' | 'ON_NO_INTERNET_CONNECTION';

  interface CieManager {
    isNFCEnabled(): Promise<boolean>;
    hasNFCFeature(): Promise<boolean>;
    setPin(pin: string): void;
    // Set a listener on all possible CIEEvent (see above)
    // during reading and decoding of the nfc tag
    onEvent(callback: (event: CIEEvent) => void): void;
    // An error can be raised if it fails on: reading/writing tag or authentication fails
    onError(callback: (error: Error) => void): void;
    // When the CIE authentication completes successfully the consent form url will be returned
    onSuccess(callback: (url: string) => void): void;
    setAuthenticationUrl(url: string): void;
    start(): Promise<void>;
    startListeningNFC(): Promise<void>;
    stopListeningNFC(): Promise<void>;
    // Remove all events callbacks: onEvent / onError / onSuccess
    removeAllListeners(): void;
  }

  const cieManager: CieManager;
}

export default cieManager;

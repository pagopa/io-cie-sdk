// Type definitions for react-native-cie
// Project: https://github.com/teamdigitale/io-cie-android-sdk
declare module "react-native-cie" {

  // All events that can return from the method 'setEventListener'
  export type EventValue = 'ON_TAG_DISCOVERED_NOT_CIE' | 'ON_TAG_DISCOVERED' | 'ON_TAG_LOST' |
  'ON_CARD_PIN_LOCKED' | 'ON_PIN_ERROR' | 'CERTIFICATE_EXPIRED' | 'CERTIFICATE_REVOKED' |
  'AUTHENTICATION_ERROR' | 'ON_NO_INTERNET_CONNECTION';

  interface CieManager {
    isNFCEnabled(): Promise<boolean>;
    hasNFCFeature(): Promise<boolean>;
    setPin(pin: string): void;
    // The next 3 methods must be implemented to listen the messages
    // from the sdk, errors, and url to access
    setEventListener(callback: (eventCallback: EventValue) => void): void;
    setErrorListener(callback: (eventCallback: any) => void): void;
    setSuccessListener(callback: (eventCallback: any) => void): void;
    setAuthenticationUrl(url: string): void;
    start(): Promise<never>;
    startListeningNFC(): Promise<never>;
    stopListeningNFC(): Promise<never>;
  }

  const cieManager: CieManager;
}

export default cieManager;

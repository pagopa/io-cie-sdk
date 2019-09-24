// Type definitions for react-native-cie
// Project: https://github.com/teamdigitale/io-cie-android-sdk
declare module "react-native-cie" {

  export type EventValue = 'ON_TAG_DISCOVERED_NOT_CIE' | 'ON_TAG_DISCOVERED' | 'ON_TAG_LOST' |
  'ON_CARD_PIN_LOCKED' | 'ON_PIN_ERROR' | 'CERTIFICATE_EXPIRED' | 'CERTIFICATE_REVOKED' |
  'AUTHENTICATION_ERROR' | 'ON_NO_INTERNET_CONNECTION';

  interface CieManager {
    isNFCEnabled(): Promise<boolean>;
    hasNFCFeature(): Promise<boolean>;
    setPin(pin: string): void;
    onEvent(callback: (event: EventValue) => void): void;
    setAuthenticationUrl(url: string): void;
    start(): Promise<never>;
    startListeningNFC(): Promise<never>;
    stopListeningNFC(): Promise<never>;
  }

  const cieManager: CieManager;
}

export default cieManager;

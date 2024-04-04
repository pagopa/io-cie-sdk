// Type definitions for react-native-cie
// Project: https://github.com/pagopa/io-cie-android-sdk

// All events returned by onEvent callback
type CIEEvent =
  | "ON_TAG_DISCOVERED_NOT_CIE"
  | "ON_TAG_DISCOVERED"
  | "ON_TAG_LOST"
  | "ON_CARD_PIN_LOCKED"
  | "ON_PIN_ERROR"
  | "PIN_INPUT_ERROR"
  | "CERTIFICATE_EXPIRED"
  | "CERTIFICATE_REVOKED"
  | "AUTHENTICATION_ERROR"
  | "ON_NO_INTERNET_CONNECTION"
  | "STOP_NFC_ERROR"
  | "START_NFC_ERROR"
  | "EXTENDED_APDU_NOT_SUPPORTED"
  // iOS dedicated events
  | "PIN Locked"
  | "TAG_ERROR_NFC_NOT_SUPPORTED"
  | "Transmission Error";

type iOSAlertMessageKeys =
  | "readingInstructions"
  | "moreTags"
  | "readingInProgress"
  | "readingSuccess"
  | "invalidCard"
  | "tagLost"
  | "cardLocked"
  | "wrongPin1AttemptLeft"
  | "wrongPin2AttemptLeft"
  | "genericError";

export type Event = {
  event: CIEEvent;
  attemptsLeft: number;
};

declare class CieManager {
  /**
   * check if the OS support CIE autentication
   */
  hasApiLevelSupport(): Promise<boolean>;

  /**
   * check if the device has NFC feature
   */
  hasNFCFeature(): Promise<boolean>;

  /**
   * check if the device running the code supports CIE authentication
   */
  isCIEAuthenticationSupported(): Promise<boolean>;

  /**
   * check if NFC is enabled
   */
  isNFCEnabled(): Promise<boolean>;

  /**
   * launch CieID app (https://play.google.com/store/apps/details?id=it.ipzs.cieid&hl=it)
   * if it's installed. Otherwise the default browser is opened on the app url
   */
  launchCieID(): Promise<void>;

  /**
   * register a callback to receive all Event raised while reading/writing CIE
   */
  onEvent(callback: (event: Event) => void): void;
  /**
   * opens OS Settings on NFC section
   */

  openNFCSettings(): Promise<void>;
  /**
   * register a callback to receive errors occured while reading/writing CIE
   */

  onError(callback: (error: Error) => void): void;

  /**
   * register a callback to receive the success event containing the consent form url
   */
  onSuccess(callback: (url: string) => void): void;

  /**
   * Enable/Disable CIE SDK logs
   * @param isEnabled true to enable logs, false to disable
   */
  enableLog(isEnabled: boolean): void;

  /**
   * set a custom IdP url, leave it empty to use the default one
   * @param idpUrl the cutom IdP url
   */
  setCustomIdpUrl(idpUrl: string?): void;

  setAuthenticationUrl(url: string): void;

  /**
   * set the CIE pin. It has to be a 8 length string of 8 digits
   */
  setPin(pin: string): Promise<void>;

  start(
    alertMessagesConfig?: Partial<Record<iOSAlertMessageKeys, string>>
  ): Promise<void>;

  /**
   * command CIE SDK to start reading/writing CIE CARD
   */
  startListeningNFC(): Promise<void>;

  /**
   * command CIE SDK to stop reading/writing CIE CARD
   */
  stopListeningNFC(): Promise<void>;

  /**
   * Remove all events callbacks: onEvent / onError / onSuccess
   */
  removeAllListeners(): void;

  /**
   * only iOS.
   * customize the info and error messages shown on NFC reading card alert
   */
  setAlertMessage(key: iOSAlertMessageKeys, value: string): void;
}

export default new CieManager();

<p align="center">
  <img src="https://raw.githubusercontent.com/pagopa/io-app/master/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png" width="100"/></br>
  IO - The public services app
</p>

- [Italiano](#italiano)
- [English](#english)

# Italiano
Questo repository contiene il porting per React Native (eseguito dal team di <a href="https://github.com/pagopa/io-app">IO</a>) dell'SDK sviluppato da IPZS (<a href="https://docs.italia.it/italia/cie/cie-manuale-tecnico-docs/it/master/cieIDSDK.html">disponibile qui</a>)
<br />

## Installazione

Per utilizzare la libreria nel tuo progetto:

```bash
npm install @pagopa/react-native-cie --save
```

La login con CIE può essere effettuata esclusivamente tramite tecnologia NFC (tecnologia di tipo Hardware).
<br />
Su iOS, il codice che implementa la tecnologia non è disponibile sul simulatore, rendendo impossibile la build.

Per superare il problema, è necessario rinominare la cartella ios in .ios. In questo modo, ReactNative non ha visibilità del codice iOS e la build va a buon fine.

Per facilitare questo passaggio e abilitare la compilazione della libreria (lanciando la build da un device reale), è stato definito il comando:
```bash
mv node_modules/@pagopa/react-native-cie/.ios node_modules/@pagopa/react-native-cie/ios 
mv node_modules/@pagopa/react-native-cie/.react-native-cie.podspec node_modules/@pagopa/react-native-cie/react-native-cie.podspec 
cd ios 
pod install
```

Per effettuare l'operazione inversa, invece:
```bash
mv node_modules/@pagopa/react-native-cie/ios node_modules/@pagopa/react-native-cie/.ios
mv node_modules/@pagopa/react-native-cie/react-native-cie.podspec node_modules/@pagopa/react-native-cie/.react-native-cie.podspec
cd ios
rm -rf Pods
pod install
```


## Compatibilità
Non tutti i device possono permettere la login con CIE. La libreria espone dei metodi per gestire le varie possibilità

### Android
Su Android, è necessario verificare la presenza dell'NFC, oltre che della versione minima dell'API (>= 23).
<br />
Recentemente, è stato scoperto che alcuni vendors disabilitano la funzionalità <strong>software extended APDU</strong>, rendendo impossibile la lettura/scrittura tramite NFC. <br />
Purtroppo, non è possibile determinare a priori questa possibilità, ma può essere gestito l'errore ritornato dall'SDK in fase di lettura.

### iOS
Su iOS, la tecnologia NFC è presente su tutti i device con iOS >= 13.


## Utilizzo
Per effettuare l'autenticazione tramite CIE, sono necessari tre componenti:
- un URI di Autenticazione;
- il PIN della CIE;
- la carta da leggere;

Il recupero di queste tre componenti non dipendono dall'SDK.
<br />
Per utilizzare l'SDK, è necessario importarlo
```ts
import cieManager from "@pagopa/react-native-cie";
```
Una volta importato, è possibile accedere a tutti i suoi metodi.

## API 
Di seguito sono elencate alcune delle funzionalità presenti. <br />
E' possibile trovare <a href="https://github.com/pagopa/io-cie-sdk/blob/master/index.d.ts">qui</a> tutte le altre.

| Function | Return | Descrizione |
| :-------- | :------- | :------------------------- |
| `hasApiLevelSupport()` | `Promise<boolean>` | (Android) Verifica se l'OS supporta l'autenticazione con CIE |
| `hasNFCFeature()` | `Promise<boolean>` | Verifica se il device ha l'NFC |
| `setPin(pin: string)` | `Promise<void>` | Set del PIN della CIE |
| `setAuthenticationUrl(url: string)` | `Promise<void>` | Set dell'Url di Autenticazione |
| `start(alertMessagesConfig?: Partial<Record<iOSAlertMessageKeys, string>>)` | `Promise<void>` | Avvia l'utilizzo dell'SDK |
| `startListeningNFC()` | `Promise<void>` | (Android) Avvia la lettura dell'NFC |
| `stopListeningNFC()` | `Promise<void>` | (Android) Stoppa la lettura dell'NFC |
| `openNFCSettings()` | `Promise<void>` | (Android) Apre le impostazioni dell'OS per l'NFC |
| `onEvent(callback: (event: Event) => void)` | `void` | Callback eseguita ad ogni evento di lettura/scrittura |
| `onError(callback: (error: Error) => void)` | `void` | Callback eseguita ad ogni errore di lettura/scrittura |
| `onSuccess(callback: (url: string) => void)` | `void` | Callback eseguita in caso di success |

## Possibili errori
Durante la lettura dell'NFC, i possibili errori sono i seguenti

| Error code | Descrizione |
| :-------- | :------------------------- |
| `ON_TAG_DISCOVERED_NOT_CIE` | (Android) La carta letta non è una CIE |
| `TAG_ERROR_NFC_NOT_SUPPORTED` | (iOS) La carta letta non è una CIE |
| `ON_TAG_DISCOVERED` | E' stato riconosciuto un tag |
| `ON_TAG_LOST` | Tag perso |
| `ON_CARD_PIN_LOCKED` | (Android) Troppi inserimenti errati del PIN, che risulta bloccato |
| `PIN Locked` | (iOS) Troppi inserimenti errati del PIN, che risulta bloccato |
| `ON_PIN_ERROR` | Pin errato. L'evento restituisce anche il numero di tentativi rimasti |
| `PIN_INPUT_ERROR` | Il PIN ha un formato errato (8 cifre numeriche) |
| `CERTIFICATE_EXPIRED` | La CIE è scaduta |
| `CERTIFICATE_REVOKED` | La CIE è stata revocata |
| `AUTHENTICATION_ERROR` | Errore di autenticazione con il server del Ministero |
| `ON_NO_INTERNET_CONNECTION` | Nessuna connesione ad Internet |
| `STOP_NFC_ERROR` | Errore durante lo stop della lettura NFC |
| `START_NFC_ERROR` | Errore durante lo start della lettura NFC |
| `EXTENDED_APDU_NOT_SUPPORTED` | Il dispositivo non supporta una caratteristica della lettura della CIE |
| `Transmission Error` | (iOS) Errore durante la trasmissione NFC |






# English
This repository contains the React Native library for <a href="https://docs.italia.it/italia/cie/cie-manuale-tecnico-docs/it/master/cieIDSDK.html">CIE integration</a>, written by <a href="https://github.com/pagopa/io-app">IO</a>
<br />

## Installation

To use the library in your project

```bash
npm install @pagopa/react-native-cie --save
```

The login with CIE works only with NFC (hardware tecnology).
<br />
On iOS, the code that implements this tecnology isn't available on simulator, so it's not possible to build the project.

To solve this issue, you can rename the ios folder into .ios. After that, ReactNative has no more visibility on the iOS part and the build goes well.

If you want, you can use these commands to enable o disable the compiling phase.<br /><br />
**Enable**
```bash
mv node_modules/@pagopa/react-native-cie/.ios node_modules/@pagopa/react-native-cie/ios 
mv node_modules/@pagopa/react-native-cie/.react-native-cie.podspec node_modules/@pagopa/react-native-cie/react-native-cie.podspec 
cd ios 
pod install
```
**Disable**
```bash
mv node_modules/@pagopa/react-native-cie/ios node_modules/@pagopa/react-native-cie/.ios
mv node_modules/@pagopa/react-native-cie/react-native-cie.podspec node_modules/@pagopa/react-native-cie/.react-native-cie.podspec
cd ios
rm -rf Pods
pod install
```


## Compatibility
Note that not all the devices can allow the CIE login. This library provides you the methods to check that.

### Android
On Android, is mandatory to check if the device has the NFC feature and the minimum version for the API (>= 23).
<br />
Recently, it was discovered a new issue. Some vendors are disabling a feature called <strong>software extended APDU</strong>. This feature disable the writing/reading through the NFC.<br />
Unfortunately, it's not possible to determinate this possibility at beginning, but it's possible to handle the error returned by the SDK while reading the CIE.

### iOS
On iOS, the NFC feature is available on all the device with iOS >=13.


## Usage
To provide the CIE authentication, 3 components are required:
- Authentication URI;
- CIE pin;
- the physical CIE to read;

It's up to you to get this components.
<br />
To use the library, just import it!
```ts
import cieManager from "@pagopa/react-native-cie";
```
Now you have access to all the methods.

## API 
A summary of some functionalities are written below, but you can find more <a href="https://github.com/pagopa/io-cie-sdk/blob/master/index.d.ts">here</a>.

| Function | Return | Desciption |
| :-------- | :------- | :------------------------- |
| `hasApiLevelSupport()` | `Promise<boolean>` | (Android) Check if OS has the minimum Api version |
| `hasNFCFeature()` | `Promise<boolean>` | Check if the device has the NFC |
| `setPin(pin: string)` | `Promise<void>` | Set the pin of the CIE|
| `setAuthenticationUrl(url: string)` | `Promise<void>` | Set the Authentication Url |
| `start(alertMessagesConfig?: Partial<Record<iOSAlertMessageKeys, string>>)` | `Promise<void>` | Start the SDK |
| `startListeningNFC()` | `Promise<void>` | (Android) Start the reading from the NFC |
| `stopListeningNFC()` | `Promise<void>` | (Android) Stop the reading from the NFC |
| `openNFCSettings()` | `Promise<void>` | (Android) Open the OS Settings for the NFC |
| `onEvent(callback: (event: Event) => void)` | `void` | Callback after any events of reading/writing |
| `onError(callback: (error: Error) => void)` | `void` | Callback after any errors of reading/writing|
| `onSuccess(callback: (url: string) => void)` | `void` | Success Callback |

## Handle errors
You can handle the errors that happens while reading the NFC.

| Error code | Description |
| :-------- | :------------------------- |
| `ON_TAG_DISCOVERED_NOT_CIE` | (Android) The card is not a CIE  |
| `TAG_ERROR_NFC_NOT_SUPPORTED` | (iOS) The card is not a CIE |
| `ON_TAG_DISCOVERED` | A tag is discovered. |
| `ON_TAG_LOST` | A tag is lost |
| `ON_CARD_PIN_LOCKED` | (Android) The CIE is locked because of too many insert of wrong PIN |
| `PIN Locked` | (iOS) The CIE is locked because of too many insert of wrong PIN |
| `ON_PIN_ERROR` | Wrong PIN. The error returns also the remaining attempts number |
| `PIN_INPUT_ERROR` | Wrong format for the PIN. It must be 8 numeric characters|
| `CERTIFICATE_EXPIRED` | Expired CIE |
| `CERTIFICATE_REVOKED` | Revoked CIE |
| `AUTHENTICATION_ERROR` | Authentication error during the communication with Government server|
| `ON_NO_INTERNET_CONNECTION` | No Internet connection |
| `STOP_NFC_ERROR` | Error while stopping the NFC reading |
| `START_NFC_ERROR` | Error while starting the NFC reading |
| `EXTENDED_APDU_NOT_SUPPORTED` | The device cannot read the CIE |
| `Transmission Error` | (iOS) Generic Error |


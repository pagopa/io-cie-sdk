<p align="center">
  <img src="https://raw.githubusercontent.com/pagopa/io-app/master/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png" width="100"/></br>
  IO - The public services app
</p>

# React-Native-Cie
Questo repository contiene il porting per React Native (eseguito dal team di <a href="https://github.com/pagopa/io-app">IO</a>) dell'SDK sviluppato da IPZS (<a href="https://docs.italia.it/italia/cie/cie-manuale-tecnico-docs/it/master/cieIDSDK.html">disponibile qui</a>)
<br />


## Per iniziare

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
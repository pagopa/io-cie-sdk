import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Platform,
} from 'react-native';
import NfcManager, {NfcTech} from 'react-native-nfc-manager';
import Apdu from './ts/apdu';

class App extends React.Component {
  componentDidMount() {
    NfcManager.start();
  }

  componentWillUnmount() {
    this._cleanUp();
  }

  render() {
    return (
      <View style={{padding: 20}}>

        <Text>NFC APDU Protocol Protocol Demo</Text>

        <TouchableOpacity
          style={{padding: 10, width: 200, margin: 20, borderWidth: 1, borderColor: 'black'}}
          onPress={this._test}
        >
          <Text>Run Test</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={{padding: 10, width: 200, margin: 20, borderWidth: 1, borderColor: 'black'}}
          onPress={this._cleanUp}
        >
          <Text>Cancel Test</Text>
        </TouchableOpacity>
      </View>
    )
  }

  _cleanUp = () => {
    NfcManager.cancelTechnologyRequest().catch(() => 0);
  }

  _test = async () => {
    try {
      let tech = NfcTech.IsoDep;
      let resp = await NfcManager.requestTechnology(tech, {
        alertMessage: 'Ready to send some APDU'
      });
      console.warn("Technology: ", resp);

      // the NFC uid can be found in tag.id
      let tag = await NfcManager.getTag();
      console.warn("Tag: ", tag);

      // Test Case 7816_A_1
      // Send the following SelectApplication APDU to the e-Passport.
      // ‘00 A4 04 0C 07 A0 00 00 02 47 10 01'
      // According to the ICAO recommendation, the P2 denotes "return no file
      // information", and there is no Le byte present. Therefore, the response data
      // field MUST be empty. The e-Passport MUST return status bytes ‘90 00’.

      let msg = new Apdu("ciao");
      console.log("Message", msg.getMessage());

      if (Platform.OS === 'ios') {
        // here we assume AID A0000002471001 for ePassport
        // you will need to declare above AID in Info.plist like this:
        // ------------------------------------------------------------
	      //   <key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
	      //   <array>
	      //   	 <string>A0000002471001</string>
	      //   </array>
        // ------------------------------------------------------------
        resp = await NfcManager.sendCommandAPDUIOS([0x00, 0x84, 0x00, 0x00, 0x08]);
        /**
         * or, you can use alternative form like this:
           resp = await NfcManager.sendCommandAPDUIOS({
             cla: 0,
             ins: 0x84,
             p1: 0,
             p2: 0,
             data: [],
             le: 8
           });
         */
      } else {
        resp = await NfcManager.transceive([0x00, 0x84, 0x00, 0x00, 0x08]);
      }
      console.warn("Transceive Response: ", resp);

      this._cleanUp();
    } catch (ex) {
      console.warn('Exception', ex);
      this._cleanUp();
    }
  }
}

export default App;

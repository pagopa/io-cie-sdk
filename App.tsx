import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  Platform,
  StyleSheet
} from 'react-native';
import NfcManager, {NfcTech} from 'react-native-nfc-manager';
import {Buffer} from 'buffer';

interface State {
  apduResponse: string;
  testOutput: boolean;
  detectedTechnology: string;
  nfcUID: string;
  showInstructions: boolean;
}

export class App extends React.Component<any, State> {

  constructor(props: any) {
    super(props);
    this.state = {
      apduResponse: "Please run the test",
      testOutput: false,
      detectedTechnology: "",
      nfcUID: "",
      showInstructions: false
    }
  }

  componentDidMount() {
    NfcManager.start();
  }

  componentWillUnmount() {
    this.cleanUp();
  }

  private cleanUp = () => {
    NfcManager.cancelTechnologyRequest().catch(() => 0);
    this.setState({
      apduResponse: "Please run the test",
      testOutput: false,
      detectedTechnology: "",
      nfcUID: "",
      showInstructions: false
    });
  }

  private test = async () => {
    try {
      let tech = NfcTech.IsoDep;

      this.setState({showInstructions: true});

      let resp = await NfcManager.requestTechnology(tech, {
        alertMessage: 'Ready to send some APDU'
      });

      // the NFC uid can be found in tag.id
      let tag = await NfcManager.getTag();


      this.setState({
        detectedTechnology: resp,
        nfcUID: tag.id
      });

      // Test Case 7816_A_1
      // Send the following SelectApplication APDU to the e-Passport.
      // ‘00 A4 04 0C 07 A0 00 00 02 47 10 01'
      // According to the ICAO recommendation, the P2 denotes "return no file
      // information", and there is no Le byte present. Therefore, the response
      // data field MUST be empty. The e-Passport MUST return status bytes 
      //‘90 00’.

      let apduAnswer = undefined;
      if (Platform.OS === 'ios') {
        apduAnswer = await NfcManager.sendCommandAPDUIOS([0x00, 0xA4, 0x04, 
          0x0C, 0x07, 0xA0, 0x00, 0x00, 0x02, 0x47, 0x10, 0x01]);
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
        apduAnswer = await NfcManager.transceive([0x00, 0xA4, 0x04, 0x0C, 0x07, 
          0xA0, 0x00, 0x00, 0x02, 0x47, 0x10, 0x01]);
      }
    
      let humanReadableResponse = Buffer.from(apduAnswer).toString('hex');

      this.setState({
        apduResponse: humanReadableResponse,
        testOutput: (humanReadableResponse === '9000'),
        showInstructions: false}
      );
    } catch (ex) {
      console.warn('Exception', ex);
      //TODO: Buggy logic to decide when to do the cleanings. Resolve.
      this.cleanUp();
    }
  }

  render() {
    return (
      <View style={{padding: 20}}>

        <Text style={[styles.textLabel]}>NFC APDU Protocol Protocol Demo</Text>
        <Text style={[styles.textNormal]}>
          This utility runs ICAO Test Case 7816_A_1, which consists in sending 
          the APDU message 0x00A4040C07A0000002471001 to the CIE and waiting back
          for the reply 0x9000.
        </Text>

        <TouchableOpacity
          style={[styles.primaryButton]}
          onPress={this.test}
        >
          <Text>RUN ICAO TEST CASE 7816_A_1</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.primaryButton]}
          onPress={this.cleanUp}
        >
          <Text>CANCEL TEST</Text>
        </TouchableOpacity>

        {this.state.showInstructions &&
          <Text style={[styles.textWarning]}>
            Please move the CIE near the mobile phone! 
          </Text>
        }

        <Text style={[styles.textLabel]}>
          ICAO Test Case 7816_A_1 results:
        </Text>

        <Text style={[styles.textNormal]}>
          Technology: {this.state.detectedTechnology}
        </Text>
        
        <Text style={[styles.textNormal]}>
          NFC UID: {this.state.nfcUID}
        </Text>

        <View style={[styles.textBox, this.state.testOutput? styles.success : 
          styles.error]}>
          <Text>
            {this.state.apduResponse}
          </Text>
        </View>

      </View>
    )
  }
}

const styles = StyleSheet.create({
  textBox: {
    padding: 10, width: 250, marginLeft: 20, marginRight: 20, marginTop: 10, 
    marginBottom: 10, borderWidth: 1
  },
  primaryButton: {
    padding: 10, width: 250, marginLeft: 20, marginRight: 20, marginTop: 10, 
    marginBottom: 10, borderWidth: 1, backgroundColor: 'cyan'
  },
  textLabel: {
    padding: 10, marginTop: 10, marginBottom: 20, fontWeight: 'bold'
  },
  textNormal : {
    padding: 0, marginLeft: 20
  },
  textWarning: {
    padding: 0, marginLeft: 20, fontWeight: 'bold', color: 'red'
  },
  success: {
      borderColor: 'green',
  },
  error: {
      borderColor: 'red',
  },
});

export default App;

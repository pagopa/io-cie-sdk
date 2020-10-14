/*
LICENSE
*/


// Class for creating, manipulating and transcoding APDU messages
// Heavily relying reli
class Apdu {

  apduMessage: Buffer;

  constructor(message: string) {
    this.apduMessage = message;
  }

  getMessage() {
    return apduMessage;
  }

}

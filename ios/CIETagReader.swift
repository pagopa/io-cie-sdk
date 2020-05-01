//
//  CIETagReader.swift
//  NFCTest
//
//

import Foundation
import CoreNFC

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
    
    static func dataWithHexString(hex: String) -> Data {
        var hex = hex
        var data = Data()
        while(hex.count > 0) {
            let subIndex = hex.index(hex.startIndex, offsetBy: 2)
            let c = String(hex[..<subIndex])
            hex = String(hex[subIndex...])
            var ch: UInt32 = 0
            Scanner(string: c).scanHexInt32(&ch)
            var char = UInt8(ch)
            data.append(&char, count: 1)
        }
        return data
    }
}

public class TagError : Error {
    init(errorDescription: String)
    {
        self.errorDescription = errorDescription
    }

    public var errorDescription: String
    
}

public class CIETagError : TagError {
    
    init(sw1sw2: UInt16)
    {
        self.sw1sw2 = sw1sw2
        super.init(errorDescription: ErrorHelper.decodeError(error: sw1sw2))
    }
    
    public var sw1sw2 : UInt16
}

public class CIETagReader {
    var tag : NFCISO7816Tag
    var nfcToken : NFCToken
    let cieToken : CIEToken
    
    init( tag: NFCISO7816Tag) {
        self.tag = tag
        nfcToken = NFCToken(tag: self.tag)
        cieToken = CIEToken(nfcToken: nfcToken)
    }

    public func post(url: String, pin: String, data: String?, completed: @escaping (Data?, UInt16)->() )  {
        
        let concurrentQueue = DispatchQueue(label: "nfcthread", qos: .userInteractive, attributes: .concurrent)
        
        print("start autenticazione SSL")
        
        concurrentQueue.async {

            var sw = self.cieToken.authenticate()
            if(sw != 0x9000)
            {
                completed(nil, sw)
                return;
            }
            
            sw = self.cieToken.verifyPIN(pin)
            if(sw != 0x9000)
            {
                completed(nil, sw)
                return;
            }
            
            let certificate = NSMutableData()
            sw = self.cieToken.certificate(certificate)
            if(sw != 0x9000)
            {
                completed(nil, sw)
                return;
            }
            
            // post
            let respone = NSMutableData()
            sw = self.cieToken.post(url, pin: pin, certificate: certificate as Data, data: data, response: respone)
            if(sw != 0)
            {
                print("error \(sw)")
                completed(nil, sw)
            }
            else
            {
                completed(respone as Data, 0)
            }
        }
    }

}


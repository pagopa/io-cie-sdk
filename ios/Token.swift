//
//  Token.swift
//
//  Created by ugo chirico on 22/12/2019.
//

import Foundation
import CoreNFC

public struct ResponseAPDU {
    
    public var data : [UInt8]
    public var sw1 : UInt8
    public var sw2 : UInt8

    public init(data: [UInt8], sw1: UInt8, sw2: UInt8) {
        self.data = data
        self.sw1 = sw1
        self.sw2 = sw2
    }
}


@objc public class NFCToken : NSObject {
    
    var tag : NFCISO7816Tag
    
    @objc init( tag: NFCISO7816Tag) {
        self.tag = tag
    }

    @objc public func transmit(apdu: Data) -> Data
    {
        let cmd : NFCISO7816APDU = NFCISO7816APDU(data: apdu)!
        var responseAPDU : ResponseAPDU? = nil
        let semaphore = DispatchSemaphore(value: 0)
        var error : Error? = nil
        
        let concurrentQueue = DispatchQueue(label: "nfcthread", qos: .background, attributes: .concurrent)
        
        concurrentQueue.async {
            
            self.send(cmd: cmd) { (respAPDU, err) in
                if(err == nil)
                {
                    responseAPDU = respAPDU!
                }
                else
                {
                    print(error ?? "error")
                    error = err
                }
                semaphore.signal()
            }
        }
                
        if(responseAPDU == nil)
        {
            semaphore.wait()
        }

        if(error == nil)
        {
            var response : Data = Data();
            
            response.append(contentsOf: responseAPDU!.data)
            response.append(responseAPDU!.sw1)
            response.append(responseAPDU!.sw2)

            return response
        }
        
        return Data();
    }
    
    func send( cmd: NFCISO7816APDU, completed: @escaping (ResponseAPDU?, Error?)->() ) {
                    
        tag.sendCommand(apdu: cmd) { (data, sw1, sw2, error) in
            if error == nil
            {
                let rep = ResponseAPDU(data: [UInt8](data), sw1: sw1, sw2: sw2)
                completed( rep, nil )
            }
            else
            {
                completed( nil, error)
            }
        }
    }
}


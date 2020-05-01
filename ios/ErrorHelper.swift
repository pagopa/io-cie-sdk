//
//  ErrorHelper.swift
//  CIESDK
//
//  Created by ugo chirico on 12.03.2020.
//

import Foundation

public class ErrorHelper {
    
    public static let TAG_ERROR_SESSION_INVALIDATED : UInt16 = 10
    public static let TAG_ERROR_NFC_NOT_SUPPORTED : UInt16 = 11
    
    @objc public static func decodeError( error: UInt16) -> String {
        
        if(error < 100)
        {
            return decodeTagSessionError(err: error)
        }
        else if (error < 1000)
        {
            return decodeHTTPError(err: error)
        }
        else
        {
            return decodeCIEError(sw1sw2: error)
        }
    }
    
    @objc public static func decodeCIEError( sw1sw2: UInt16) -> String {
        
        let sw1 : UInt8 = (UInt8)((sw1sw2 >> 8) & 0x00FF);
        let sw2 : UInt8 = (UInt8)((sw1sw2) & 0x00FF);
        
        return decodeError(sw1: sw1, sw2: sw2)
    }
        
    @objc public static func decodeHTTPError( err:UInt16 ) -> String {
        return "HTTP Error \(err)"
    }
    
    @objc public static func decodeTagSessionError( err:UInt16 ) -> String {
        return "Tag Session Error \(err)"
    }

    @objc public static func decodeError( sw1: UInt8, sw2:UInt8 ) -> String {

        let errors : [UInt8 : [UInt8:String]] = [
            0x62: [0x00:"No information given",
                   0x81:"Part of returned data may be corrupted",
                   0x82:"End of file/record reached before reading Le bytes",
                   0x83:"Selected file invalidated",
                   0x84:"FCI not formatted according to ISO7816-4 section 5.1.5"],
            
            0x63: [0x00:"No information given",
                   0x81:"File filled up by the last write",
                   0x82:"Card Key not supported",
                   0x83:"Reader Key not supported",
                   0x84:"Plain transmission not supported",
                   0x85:"Secured Transmission not supported",
                   0x86:"Volatile memory not available",
                   0x87:"Non Volatile memory not available",
                   0x88:"Key number not valid",
                   0x89:"Key length is not correct",
                   0xC1:"Wrong PIN, 1 attempt left",
                   0xC2:"Wrong PIN, 2 attempts left",
                   0xC:"Counter provided by X (valued from 0 to 15) (exact meaning depending on the command)"],
            0x65: [0x00:"No information given",
                   0x81:"Memory failure"],
            0x67: [0x00:"Wrong length"],
            0x68: [0x00:"No information given",
                   0x81:"Logical channel not supported",
                   0x82:"Secure messaging not supported"],
            0x69: [0x00:"No information given",
                   0x81:"Command incompatible with file structure",
                   0x82:"Security status not satisfied",
                   0x83:"Authentication method blocked",
                   0x84:"Referenced data invalidated",
                   0x85:"Conditions of use not satisfied",
                   0x86:"Command not allowed (no current EF)",
                   0x87:"Expected SM data objects missing",
                   0x88:"SM data objects incorrect"],
            0x6A: [0x00:"No information given",
                   0x80:"Incorrect parameters in the data field",
                   0x81:"Function not supported",
                   0x82:"File not found",
                   0x83:"Record not found",
                   0x84:"Not enough memory space in the file",
                   0x85:"Lc inconsistent with TLV structure",
                   0x86:"Incorrect parameters P1-P2",
                   0x87:"Lc inconsistent with P1-P2",
                   0x88:"Referenced data not found"],
            0x6B: [0x00:"Wrong parameter(s) P1-P2]"],
            0x6D: [0x00:"Instruction code not supported or invalid"],
            0x6E: [0x00:"Class not supported"],
            0x6F: [0x00:"No precise diagnosis"],
            0x90: [0x00:"Success"], //No further qualification
            0xFF: [0x01:"Invalid CIE Certificate",
                   0xFB:"Nuovo PIN e vecchio PIN non devono essere uguali",
                   0xFC:"I PIN non corrispondono",
                   0xFD:"Il PIN deve essere composto da 8 numeri",
                   0xFE:"Il nuovo PIN non deve avere cifre uguali o consecutive",
                   0xFF:"Transmission Error"]
        ]
        
        // Special cases - where sw2 isn't an error but contains a value
        if sw1 == 0x61 {
            return "SW2 indicates the number of response bytes still available - (\(sw2) bytes still available)"
        } else if sw1 == 0x64 {
            return "State of non-volatile memory unchanged (SW2=00, other values are RFU)"
        } else if sw1 == 0x6C {
            return "Wrong length Le: SW2 indicates the exact length - (exact length :\(sw2))"
        }

        if let dict = errors[sw1], let errorMsg = dict[sw2] {
            return errorMsg
        }
        
        return "Unknown error - sw1: \(sw1), sw2: \(sw2)"
    }
}

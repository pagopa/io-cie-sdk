//
//  CIEIDSdk.swift
//  NFCTest
//

import UIKit
import CoreNFC

extension URL {
    var queryParameters: QueryParameters { return QueryParameters(url: self) }
}

class QueryParameters {
    let queryItems: [URLQueryItem]
    init(url: URL?) {
        queryItems = URLComponents(string: url?.absoluteString ?? "")?.queryItems ?? []
        print(queryItems)
    }
    subscript(name: String) -> String? {
        return queryItems.first(where: { $0.name == name })?.value
    }
}

struct Constants {
    static let KEY_VALUE = "value"
    static let KEY_AUTHN_REQUEST_STRING = "authnRequestString"
    static let KEY_NAME = "name"
    static let KEY_NEXT_UTL = "nextUrl"
    static let KEY_OP_TEXT = "OpText"
    static let KEY_LOGO = "imgUrl"
    static let generaCodice = "generaCodice"
    static let authnRequest = "authnRequest"
    static let BASE_URL_IDP = "https://idserver.servizicie.interno.gov.it/idp/Authn/SSL/Login2"
    //PRODUZIONE
    //"https://idserver.servizicie.interno.gov.it/idp/"
    //COLLAUDO
    //"https://idserver.servizicie.interno.gov.it:8443/idp/"
}

@objc(CIEIDSdk)
public class CIEIDSdk : NSObject, NFCTagReaderSessionDelegate {
    
    private var readerSession: NFCTagReaderSession?
    private var cieTag: NFCISO7816Tag?
    private var cieTagReader : CIETagReader?
    private var completedHandler: ((UInt16, String?)->())!
    
    private var url : String?
    private var pin : String?    
    
    override public init( ) {
        super.init()
        
        cieTag = nil
        cieTagReader = nil
        url = nil
    }
    
    private func start(completed: @escaping (UInt16, String?)->() ) {
        self.completedHandler = completed
        
        guard NFCTagReaderSession.readingAvailable else {
            completedHandler( ErrorHelper.TAG_ERROR_NFC_NOT_SUPPORTED, nil)//TagError(errorDescription: "NFCNotSupported"))
            return
        }
        
        Log.debug( "authenticate" )
        
        if NFCTagReaderSession.readingAvailable {
            Log.debug( "readingAvailable" )
            readerSession = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: nil)
            readerSession?.alertMessage = "Poggia la cie sul restro dell'iphone in prossimità del lettore NFC."
            readerSession?.begin()
        }
    }
    
    @objc
    public func post(url: String, pin: String, completed: @escaping (UInt16, String?)->() ) {
           self.pin = pin
           self.url = url

           self.start(completed: completed)
    }

    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        Log.debug( "tagReaderSessionDidBecomeActive" )
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        Log.debug( "tagReaderSession:didInvalidateWithError - \(error)" )
        if(self.readerSession != nil)
        {
          
            self.readerSession = nil
            self.completedHandler(ErrorHelper.TAG_ERROR_SESSION_INVALIDATED, nil)
        }
        
        self.readerSession = nil
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        Log.debug( "tagReaderSession:didDetect - \(tags[0])" )
        if tags.count > 1 {
            session.alertMessage = "More than 1 tags was found. Please present only 1 tag."
            return
        }
        
        let tag = tags.first!
        
        switch tags.first! {
        case let .iso7816(tag):
            cieTag = tag
        default:
            session.invalidate(errorMessage: "Tag not valid.")
            return
        }
        
        // Connect to tag
        session.connect(to: tag) { [unowned self] (error: Error?) in
            if error != nil {
                session.invalidate(errorMessage: "Connection error. Please try again.")
                return
            }
            
            self.readerSession?.alertMessage = "Lettura CIE ....."
            self.cieTagReader = CIETagReader(tag:self.cieTag!)
            self.startReading( )
        }
    }

    func startReading()
    {
        //ATR is not available on IOS
        // print("iso7816Tag historical bytes \(String(data: self.passportTag!.historicalBytes!, encoding: String.Encoding.utf8))")
        //
        // print("iso7816Tag identifier \(String(data: self.passportTag!.identifier, encoding: String.Encoding.utf8))")
        //
                      
        print(self.url!)
        
        let url1 = URL(string: self.url!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        
      let value = url1!.queryParameters[Constants.KEY_VALUE]!
      let name = url1!.queryParameters[Constants.KEY_NAME]!
      let authnRequest = url1!.queryParameters[Constants.KEY_AUTHN_REQUEST_STRING]!
      let nextUrl = url1!.queryParameters[Constants.KEY_NEXT_UTL]!
      let opText = url1!.queryParameters[Constants.KEY_OP_TEXT]!
      let logo = url1?.queryParameters[Constants.KEY_LOGO]!

        let params = "\(value)=\(name)&\(Constants.authnRequest)=\(authnRequest)&\(Constants.generaCodice)=1"
        
        self.cieTagReader?.post(url: Constants.BASE_URL_IDP, pin: self.pin!, data: params, completed: { (data, error) in
          
            let  session = self.readerSession
            self.readerSession = nil
            session?.invalidate()
            
            if(error == 0)
            {
              let response = String(data: data!, encoding: .utf8)
              
              print("response: \(response ?? "nil")")
              	
                let codiceServer = String((response?.split(separator: ":")[1])!)
              
              let newurl = nextUrl + "?" + name + "=" + value + "&login=1&codice=" + codiceServer

                self.completedHandler(0, newurl)
            }
            else
            {
                self.completedHandler(error, nil)
            }
        })
    }
}

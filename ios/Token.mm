//
//  Token.m
//  e-id
//
//  Created by ugo chirico on 22/12/2019.
//  Copyright © 2019 Francesco Tufano. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import "Token.h"
#import "wintypes.h"
#import <RNNativeCiesdk-Swift.h>
#import "HTTPSConnection.h"
#import "IAS.h"
#import "util.h"

@interface CIEToken()
    @property NFCToken* token;
    @property ByteDynArray idServiziData;
    @property ByteDynArray serialData;
    @property ByteDynArray certificateData;
    @property IAS* ias;
@end

CIEToken* cieToken;

extern "C" {

short sign(unsigned char* data, size_t len, unsigned char* signature, size_t *pSignatureLen)
{
    
    printf("sign\n");
    ByteArray toSign((BYTE*)data, len);
        
    ByteDynArray sig;
        
    try
    {
        NSLog(@"tosig: %ld, %s", toSign.size(), dumpHexData(toSign).c_str());
        
        cieToken.ias->Sign(toSign, sig);
    
        printf("signk\n");
        
        *pSignatureLen = sig.size();
        memcpy(signature, sig.data(), sig.size());
        
        NSLog(@"sig: %ld, %s", sig.size(), dumpHexData(sig).c_str());
        return 0x9000;
    }
    catch (scard_error err)
    {
        return err.sw;
    }
}

}


StatusWord Transmit(ByteArray apdu, ByteDynArray *resp)
{
    
    NSData *data = [NSData dataWithBytes:apdu.data() length:apdu.size()];
    
    NSData* response = [cieToken transmit:data];
        
    StatusWord sw;
    if(response.length > 0)
    {
        ByteArray baresp((unsigned char*)response.bytes, response.length - 2);
            
        resp->append(baresp);
        
        sw = ((unsigned char*)response.bytes)[response.length - 2] * 256 + ((unsigned char*)response.bytes)[response.length - 1];
    }
    else
    {
        sw = 0xFFFF;
    }
    
    return sw;
}



@implementation CIEToken

bool authenticated = false;

- (CIEToken*) initWithNFCToken: (NFCToken*) token
{
    self = [super init];
    if(self)
    {
        self.token = token;
    }
    
    cieToken = self;
    
    _ias = new IAS(&Transmit);
    
    return self;
}

- (UInt16) authenticate
{
    try
    {
        _ias->SelectAID_IAS();
        _ias->SelectAID_CIE();
        _ias->InitDHParam();
        
        ByteDynArray IdServizi;
        _ias->ReadIdServizi(IdServizi);
        _idServiziData = IdServizi.left(12);
        _idServiziData.push(0);
    
        ByteDynArray data;
        _ias->ReadDappPubKey(data);
        _ias->InitExtAuthKeyParam();
        _ias->DHKeyExchange();
        _ias->DAPP();
                                
        authenticated = true;
        
        return 0x9000;
    }
    catch (scard_error err)
    {
        return err.sw;
    }
}

- (UInt16) verifyPIN: (NSString*) pin
{
    //uint8_t pin[] = {0x31,0x31, 0x32, 0x32, 0x33, 0x33, 0x34, 0x34};
    ByteArray bapin((BYTE*)pin.UTF8String, pin.length);
    
    try
    {
        StatusWord sw = _ias->VerifyPIN(bapin);
        NSLog(@"sw: %x", sw);
        return sw;
    }
    catch (scard_error err)
    {
        
        return err.sw;
    }
}

- (UInt16) certificate: (NSMutableData*) certificate
{
    if(cieToken.certificateData.size() != 0)
    {
        [certificate appendBytes:cieToken.certificateData.data() length: cieToken.certificateData.size()];
        
        return 0x9000;
    }

    try
    {
        ByteDynArray c;
        cieToken.ias->ReadCertCIE(c);
        
        cieToken.certificateData = c;

        [certificate appendBytes:cieToken.certificateData.data() length: cieToken.certificateData.size()];
                
        return 0x9000;
    }
    catch (scard_error err)
    {
        
        return err.sw;
    }
}

- (UInt16) post: (NSString*) url pin: (NSString*) pin certificate: (NSData*) certificate data: ( NSString* _Nullable ) data response: (NSMutableData*) response
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
    __block UInt16 errcode;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        HTTPSConnection* https = [[HTTPSConnection alloc] init];
        
        [https postTo:url withPIN:pin withCertificate:certificate withData:data callback:^(int code, NSData * _Nonnull respData) {
            NSLog(@"%d, %@", code, respData);
            
            errcode = code;
            
            if(errcode == 0)
            {
                [response appendData:respData];
            }
            
            dispatch_semaphore_signal(semaphore);
        }];
    });
                   
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return errcode;
}

- (NSData*) transmit: (NSData*) apdu
{
    NSData* resp = [self.token transmitWithApdu: apdu];
    
    return resp;
    
//    return ByteDynArray(resp.bytes, resp.bytes.count);
}

@end

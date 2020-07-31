//
//  CIEEngine.h
//  CIESDK
//
//  Created by ugo chirico on 26.02.2020.
//

#ifndef CIEEngine_h
#define CIEEngine_h

#include <stdio.h>
#include <openssl/crypto.h>
#include <openssl/objects.h>
#include <openssl/engine.h>

void engine_load_cie(void);

short sign(unsigned char* tosign, size_t len, unsigned char* signature, size_t* psiglen);

#endif /* CIEEngine_h */

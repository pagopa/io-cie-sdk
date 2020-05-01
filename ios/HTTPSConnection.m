//
//  HTTPSConnection.m
//  CIESDK
//
//  Created by ugo chirico on 29.02.2020.
//

#import "HTTPSConnection.h"

#include <curl/curl.h>
#include <openssl/engine.h>
#include <openssl/bio.h>
#include <openssl/ssl.h>
#include "CIEEngine.h"

void dump(const char *text,
          FILE *stream, unsigned char *ptr, size_t size,
          char nohex)
{
  size_t i;
  size_t c;
 
  unsigned int width = 0x10;
 
  if(nohex)
    /* without the hex output, we can fit more on screen */
    width = 0x40;
 
  fprintf(stream, "%s, %10.10lu bytes (0x%8.8lx)\n",
          text, (unsigned long)size, (unsigned long)size);
 
  for(i = 0; i<size; i += width) {
 
    fprintf(stream, "%4.4lx: ", (unsigned long)i);
 
    if(!nohex) {
      /* hex not disabled, show it */
      for(c = 0; c < width; c++)
        if(i + c < size)
          fprintf(stream, "%02x ", ptr[i + c]);
        else
          fputs("   ", stream);
    }
 
    for(c = 0; (c < width) && (i + c < size); c++) {
      /* check for 0D0A; if found, skip past and start a new line of output */
      if(nohex && (i + c + 1 < size) && ptr[i + c] == 0x0D &&
         ptr[i + c + 1] == 0x0A) {
        i += (c + 2 - width);
        break;
      }
      fprintf(stream, "%c",
              (ptr[i + c] >= 0x20) && (ptr[i + c]<0x80)?ptr[i + c]:'.');
      /* check again for 0D0A, to avoid an extra \n if it's at width */
      if(nohex && (i + c + 2 < size) && ptr[i + c + 1] == 0x0D &&
         ptr[i + c + 2] == 0x0A) {
        i += (c + 3 - width);
        break;
      }
    }
    fputc('\n', stream); /* newline */
  }
  fflush(stream);
}
 
static
int ssltrace(CURL *handle, curl_infotype type,
             char *data, size_t size,
             void *userp)
{
  const char *text;
  (void)handle; /* prevent compiler warning */
 
  switch(type) {
  case CURLINFO_TEXT:
    fprintf(stderr, "== Info: %s", data);
    /* FALLTHROUGH */
  default: /* in case a new one is introduced to shock us */
    return 0;
 
  case CURLINFO_HEADER_OUT:
    text = "=> Send header";
    break;
  case CURLINFO_DATA_OUT:
    text = "=> Send data";
    break;
  case CURLINFO_SSL_DATA_OUT:
    text = "=> Send SSL data";
    break;
  case CURLINFO_HEADER_IN:
    text = "<= Recv header";
    break;
  case CURLINFO_DATA_IN:
    text = "<= Recv data";
    break;
  case CURLINFO_SSL_DATA_IN:
    text = "<= Recv SSL data";
    break;
  }
 
  dump(text, stderr, (unsigned char *)data, size, 0);
  return 0;
}


int init_ssl_engine()
{
    ENGINE_load_builtin_engines();
    
    ENGINE* e = ENGINE_by_id("cie");
    
    if(e == NULL)
    {
        engine_load_cie();
        e = ENGINE_by_id("cie");
    }
    
    if(e == NULL)
    {
        return -1;
    }
    
    return 0;
}

struct MemoryStruct {
  char *memory;
  size_t size;
};

static size_t
write_memory_callback(void *contents, size_t size, size_t nmemb, void *userp)
{
  size_t realsize = size * nmemb;
  struct MemoryStruct *mem = (struct MemoryStruct *)userp;
 
  char *ptr = realloc(mem->memory, mem->size + realsize + 1);
  if(ptr == NULL) {
    /* out of memory! */
    printf("not enough memory (realloc returned NULL)\n");
    return 0;
  }
 
  mem->memory = ptr;
  memcpy(&(mem->memory[mem->size]), contents, realsize);
  mem->size += realsize;
  mem->memory[mem->size] = 0;
 
  return realsize;
}

extern unsigned char* cie_certificate;
extern unsigned int cie_certlen;
extern char* cie_pin;
extern unsigned int cie_pinlen;
extern unsigned short cie_error;

long bio_dump_callback(BIO *bio, int cmd, const char *argp,
                       int argi, long argl, long ret)
{
    BIO *out;

    out = (BIO *)BIO_get_callback_arg(bio);
    if (out == NULL)
        return (ret);

    if (cmd == (BIO_CB_READ | BIO_CB_RETURN)) {
        BIO_printf(out, "read from %p [%p] (%lu bytes => %ld (0x%lX))\n",
                   (void *)bio, (void *)argp, (unsigned long)argi, ret, ret);
        BIO_dump(out, argp, (int)ret);
        return (ret);
    } else if (cmd == (BIO_CB_WRITE | BIO_CB_RETURN)) {
        BIO_printf(out, "write to %p [%p] (%lu bytes => %ld (0x%lX))\n",
                   (void *)bio, (void *)argp, (unsigned long)argi, ret, ret);
        BIO_dump(out, argp, (int)ret);
    }
    return (ret);
}

int https_post(char* szUrl, char* szPIN, unsigned char* certificate, size_t certlen, char* data, size_t length, unsigned char* response, size_t* pLength)
{
    CURL *curl;
    CURLcode res = CURLE_OK;
    
    cie_certlen = certlen;
    cie_certificate = certificate;
    cie_pin = szPIN;
    cie_pinlen = strlen(szPIN);
    
    const char *pKeyName;
    const char *pKeyType;
    const char *pEngine;

    pKeyName = "auth";
    pKeyType = "ENG";
    pEngine = "cie";
        
    curl_global_init(CURL_GLOBAL_DEFAULT);

    int trace = 1;
    struct MemoryStruct chunk;
    chunk.memory = malloc(1);  /* will be grown as needed by the realloc above */
    chunk.size = 0;    /* no data at this point */
    
    curl = curl_easy_init();
    if (curl)
    {
        curl_easy_setopt(curl, CURLOPT_DEBUGFUNCTION, ssltrace);
        curl_easy_setopt(curl, CURLOPT_DEBUGDATA, &trace);
        curl_easy_setopt(curl, CURLOPT_SSLCERT,"cie");
        curl_easy_setopt(curl, CURLOPT_SSLKEY,"cie");
        curl_easy_setopt(curl, CURLOPT_VERBOSE,1);
        curl_easy_setopt(curl, CURLOPT_USE_SSL,CURLUSESSL_ALL);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER,0);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST,0);
        curl_easy_setopt(curl, CURLOPT_SSLENGINE,"cie");
        curl_easy_setopt(curl, CURLOPT_SSLKEYTYPE,"ENG");
        curl_easy_setopt(curl, CURLOPT_SSLCERTTYPE,"ENG");
        
        /* is redirected, so we tell libcurl to follow redirection */
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        
        //curl_easy_setopt(curl, CURLOPT_TRANSRANSFER, 1);
        curl_easy_setopt(curl, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1);
        

        /* set the file with the certs vaildating the server */
        //curl_easy_setopt(curl, CURLOPT_CAINFO, pCACertFile);

        
        /* send all data to this function  */
         curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_memory_callback);
        
        /* we pass our 'chunk' struct to the callback function */
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, (void *)&chunk);
        
        /* what call to write: */
        curl_easy_setopt(curl, CURLOPT_URL, szUrl);
        
        //set POST method
        curl_easy_setopt(curl, CURLOPT_POST, 1);

        printf("\nData %s\n\n", data);
        
        //give the data you want to post
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, data);

        //give the data lenght
        //curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, length);

        
        // copy data to POST
        //curl_easy_setopt(curl, CURLOPT_COPYPOSTFIELDS, 1L);
        
        struct curl_slist *headers = NULL;
            
        /* Remove a header curl would otherwise add by itself */
        headers = curl_slist_append(headers, "User-Agent: Mozilla/5.0");
    
        headers = curl_slist_append(headers, "Content-Type: application/x-www-form-urlencoded");
        
        /* set our custom set of headers */
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);

        /* use crypto engine */
        if (curl_easy_setopt(curl, CURLOPT_SSLENGINE, pEngine) != CURLE_OK) {
            /* load the crypto engine */
            fprintf(stderr, "can't set crypto engine\n");
        }
                
        /* Perform the request, res will get the return code */
        res = curl_easy_perform(curl);
        /* Check for errors */
        if (res != CURLE_OK)
        {
            fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
            
            if(cie_error != 0)
                res = cie_error;
        }
        else
        {
            long codeop;
            curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &codeop);
            
            res = (CURLcode)codeop;
        }
        
        /* always cleanup */
        curl_easy_cleanup(curl);
                
        /* free the custom headers */
        curl_slist_free_all(headers);
        
        memcpy(response, chunk.memory, chunk.size);
        *pLength = chunk.size;
        
        free(chunk.memory);
    }

    curl_global_cleanup();

    return res;
}

@implementation HTTPSConnection

- (id) init
{
    self = [super init];
    if(self)
    {
        init_ssl_engine();
    }
    
    return self;
}

- (void) postTo: (NSString*) url withPIN: (NSString*) pin withCertificate: (NSData*) certificate withData: ( NSString* _Nullable ) data  callback: (void(^) (int code, NSData* respData)) callback
{
    const char* szUrl = url.UTF8String;
    const char* szPin = pin.UTF8String;
    
    unsigned char response[5000];
    long len = 5000;
    int res;
    if(data)
        res = https_post(szUrl, szPin, certificate.bytes, certificate.length, data.UTF8String, data.length, response, &len);
    else
        res = https_post(szUrl, szPin, certificate.bytes, certificate.length, NULL, NULL, response, &len);
    
    if(res == CURLE_OK || res < 400)
        callback(CURLE_OK, [NSData dataWithBytes:response length:len]);
    else
        callback(res, NULL);
}

@end

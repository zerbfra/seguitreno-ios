//
//  APIClient.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 30/11/14.
//  Copyright (c) 2014 Francesco. All rights reserved.
//

#import "APIClient.h"

@implementation APIClient

+(APIClient *)sharedClient {
    static APIClient *_sharedClient = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedClient = [[self alloc] init];
        
    });
    return _sharedClient;
}


-(void) requestWithPath:(NSString*) path andParams:(NSDictionary*)parameters completion:(void (^)(NSDictionary *))completion {
    // di default timeout 20s e vita della cache di 3 minuti
    [self requestWithPath:path andParams:parameters withTimeout:20 cacheLife:3 completion:completion];
}

-(void) requestWithPath:(NSString*) path andParams:(NSDictionary*)parameters withTimeout:(int) timeout cacheLife:(int) life completion:(void (^)(NSDictionary *))completion {
    
    
    __block NSData *jsonData;
    
    // Percorso della cartella Documents
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    // Percorso per il json cache
    NSString *jsonPath = [docDir stringByAppendingPathComponent:@"/json"];
    
    NSError *error;
    //Creo folder per il json se non esiste
    if (![[NSFileManager defaultManager] fileExistsAtPath:jsonPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:jsonPath withIntermediateDirectories:NO attributes:nil error:&error];
    
    NSString *stringParams = [self dictionaryToString:parameters]; //converto il dizionario a una stringa
    // il json è specifico per ogni richiesta (path della stessa-parametri)
    NSString *fileName = [NSString stringWithFormat:@"/json_%@-%@",path,stringParams];
    NSString *filePath = [jsonPath stringByAppendingString:fileName];
    
    int min = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        // se il file esiste già ne devo controllare la data, se troppo vecchio aggiornarlo
        
        NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        NSDate *creationDate = [fileAttribs objectForKey:NSFileCreationDate]; //or NSFileModificationDate
        
        NSTimeInterval secs = [creationDate timeIntervalSinceNow];
        
        min = -secs/60;
        
        NSLog(@"%d min passed since last json downloaded",min);
        
    } else min = -1;
    
    // caso in cui siano passati più di LIFE min oppure che il file non esista [o, caso meno probabile, che la data vada indietro]
    // si considera anche il caso in cui life sia pari a 0
    // DUNQUE AGGIORNO COLLEGANDOMI AL SERVER
    if(min > life || min < 0 || life == 0) {
        NSLog(@"Remote request for %@",path);
        [self makeRequest:path withParams:parameters andTimeout:timeout completion:^(NSDictionary *result) {
            jsonData = [NSKeyedArchiver archivedDataWithRootObject:result];
            //scrivo su file
            [jsonData writeToFile:filePath atomically:YES];
            //rispondo
            
            completion(result);
        }];
        
    } else {
        // ALTRIMENTI *NON* MI COLLEGO AL SERVER: ritorno il file presente nel device
        NSLog(@"Retrieving local file data");
        NSData *storedData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
        NSDictionary *storedArray = [NSKeyedUnarchiver unarchiveObjectWithData:storedData];
        completion(storedArray);
    }
    
    
    
}

// imposta la richiesta http con il path assegnato e i vari parametri
-(void) makeRequest:(NSString*) path withParams:(NSDictionary*) parameters andTimeout:(int) timeout completion:(void (^)(NSDictionary *))completion {
    
    path = [NSString stringWithFormat:@"%@%@.php",BaseURLString,path];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    [defaultConfigObject setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSError *error = nil;
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // mando la richiesta in post con un body JSON, cosi è tutto incapsulato e non girano parametri nell'url
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters  options:NSJSONWritingPrettyPrinted error:&error]];
    [request setTimeoutInterval:timeout];
    
    // attivo l'indicatore network
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // procedo con un task per la richiesta
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    
                                                    
                                                    if (!error) {
                                                        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                                        //NSLog(@"Response: %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
                                                        if (httpResp.statusCode == 200) {
                                                            NSError *jsonParsingError = nil;
                                                            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
                                                            
                                                            if(!jsonParsingError) {
                                                                
                                                                NSString *status = [jsonDict objectForKey:@"status"];
                                                                // se non ho errore nello status passo l'object response
                                                                if(![status isEqualToString:@"error"]) {
                                                                    NSLog(@"%@ --> %@",path,status);
                                                                    // COMPLETO LA RICHIESTA POSITIVAMENTE!
                                                                    completion([jsonDict objectForKey:@"response"]);
                                                                }
                                                                else NSLog(@"Response status for %@ error: %@",path,jsonDict);
                                                            }
                                                            else  NSLog(@"Bad Server JSON: %@",httpResp);
                                                            
                                                        } else {
                                                            // HANDLE BAD RESPONSE //
                                                            NSLog(@"Bad Server response: %@",httpResp);
                                                        }
                                                    } else {
                                                        // HANDLE ERROR //
                                                        NSLog(@"Error with the request %@",error);
                                                    }
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                    });
                                                    
                                                }];
    
    // avvio il task
    [dataTask resume];
}

-(void) syncRequest:(NSString*) path withParams:(NSDictionary*) parameters andTimeout:(int) timeout completion:(void (^)(NSDictionary *))completion {
    
    path = [NSString stringWithFormat:@"%@%@.php",BaseURLString,path];
    
    NSURL * url = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSError *error = nil;
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    // mando la richiesta in post con un body JSON, cosi è tutto incapsulato e non girano parametri nell'url
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters  options:NSJSONWritingPrettyPrinted error:&error]];
    [request setTimeoutInterval:timeout];
    
    // attivo l'indicatore network
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // procedo con un task per la richiesta
    NSURLResponse* response;
    NSData* data = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
    
    if (!error) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
        if (httpResp.statusCode == 200) {
            NSError *jsonParsingError = nil;
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
            
            if(!jsonParsingError) {
                
                NSString *status = [jsonDict objectForKey:@"status"];
                // se non ho errore nello status passo l'object response
                if(![status isEqualToString:@"error"]) {
                    NSLog(@"%@ --> %@",path,status);
                    // COMPLETO LA RICHIESTA POSITIVAMENTE!
                    completion([jsonDict objectForKey:@"response"]);
                }
                else NSLog(@"Response status for %@ error: %@",path,jsonDict);
            }
            else  NSLog(@"Bad Server JSON: %@",httpResp);
            
        } else {
            // HANDLE BAD RESPONSE //
            NSLog(@"Bad Server response: %@",httpResp);
        }
    } else {
        // HANDLE ERROR //
        NSLog(@"Error with the request %@",error);
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    
}

-(void) getPageWithURL:(NSString*)urlString completion:(void (^)(NSData*))completion {
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setTimeoutInterval:20];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    
                                                    
                                                    if (!error) {
                                                        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                                        
                                                        if (httpResp.statusCode == 200) {
                                                            
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                            });
                                                            completion(data);
                                                            
                                                        } else {
                                                            // HANDLE BAD RESPONSE //
                                                            NSLog(@"Bad Server response: %@",httpResp);
                                                        }
                                                    } else {
                                                        // HANDLE ERROR //
                                                        NSLog(@"Error with the request %@",error);
                                                    }
                                                    
                                                }];
    
    
    [dataTask resume];
    
    
}


-(NSString*) dictionaryToString:(NSDictionary*) dict {
    
    NSString *stringParam = [dict description];
    stringParam = [stringParam stringByReplacingOccurrencesOfString:@" " withString:@""];
    stringParam = [stringParam stringByReplacingOccurrencesOfString:@"{" withString:@""];
    stringParam = [stringParam stringByReplacingOccurrencesOfString:@"}" withString:@""];
    stringParam = [stringParam stringByReplacingOccurrencesOfString:@";" withString:@"_"];
    stringParam = [stringParam stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    stringParam = [stringParam substringToIndex:[stringParam length]-1];
    
    return stringParam;
}


@end
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
    
    NSString *stringParams = [self dictionaryToString:parameters];
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
    if(min > life || min < 0) {
        NSLog(@"Remote request for %@",path);
        [self makeRequest:path withParams:parameters andTimeout:timeout completion:^(NSDictionary *result) {
            jsonData = [NSKeyedArchiver archivedDataWithRootObject:result];
            //scrivo su file
            [jsonData writeToFile:filePath atomically:YES];
            // rispondo
            
            completion(result);
        }];

    } else {
        //ritorno il file presente nel device
        NSLog(@"Retrieving local file data");
        NSData *storedData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
        NSDictionary *storedArray = [NSKeyedUnarchiver unarchiveObjectWithData:storedData];
        completion(storedArray);
    }
    
    
    
}


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
    
    
    [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters  options:NSJSONWritingPrettyPrinted error:&error]];
    [request setTimeoutInterval:timeout];
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
                                                                    TRC_DBG(@"%@ --> %@",path,status);
                                                                    completion([jsonDict objectForKey:@"response"]);
                                                                }
                                                                else TRC_ALT(@"Response status for %@ error: %@",path,jsonDict);
                                                            }
                                                            else  TRC_ALT(@"Bad Server JSON: %@",httpResp);
                                                            
                                                        } else {
                                                            // HANDLE BAD RESPONSE //
                                                            TRC_ERR(@"Bad Server response: %@",httpResp);
                                                        }
                                                    } else {
                                                        // HANDLE ERROR //
                                                        TRC_ERR(@"Error with the request %@",error);
                                                    }
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                    });
                                                    
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
//
//  APIClient.m
//  PriceRadar
//
//  Created by Francesco Zerbinati on 30/03/14.
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


-(void) requestWithPath:(NSString*) path andParams:(NSDictionary*)parameters completion:(void (^)(NSArray *))completion {
    [self requestWithPath:path andParams:parameters withTimeout:20 completion:completion];
}

-(NSDictionary*) createBatchRequests:(NSString*) page andParams:(NSDictionary*) parameters {
    
    NSMutableDictionary *tmpDict;
    [tmpDict setObject:parameters forKey:page];
    
    NSDictionary* copy = [tmpDict copy];
    return copy;
}

/*
-(void) requestGroup {
    
    // Create a dispatch group
    dispatch_group_t group = dispatch_group_create();
    
    for (int i = 0; i < 10; i++) {
        // Enter the group for each request we create
        dispatch_group_enter(group);
        
        
        [self requestWithPath:@"trovaTreno" andParams:@{@"numero":@"2651",@"origine":@"S01700",@"includiFermate":[NSNumber numberWithBool:false]} completion:^(NSArray *response) {
            NSLog(@"finito %d",i);
            dispatch_group_leave(group);
            
        }];
        
    }
    
    // Here we wait for all the requests to finish
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Do whatever you need to do when all requests are finished
        NSLog(@"finite tutte");
    });
    
}*/

-(void) requestGroup:(NSMutableArray*) batch completion:(void (^)(NSArray *))completion {
    
    // Create a dispatch group
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableArray *final = [NSMutableArray array];
    
    for(NSDictionary *dict in batch)
    {
        
        
        dispatch_group_enter(group);
        
        NSString* path =[dict objectForKey:@"path"];

        [self requestWithPath:path andParams:dict completion:^(NSArray *response) {
            NSLog(@"finito %@",path);
            
            // creo un nuovo dizionario che conterrà la risposta
            NSMutableDictionary *respDict = [dict mutableCopy];
            [respDict setObject:response forKey:@"response"];
            // aggiungo la risposta ad un array
            [final addObject:respDict];
            dispatch_group_leave(group);
            
        }];
        
    }
    
    
    // Here we wait for all the requests to finish
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Do whatever you need to do when all requests are finished
        NSLog(@"finite tutte");
        // mando l'array
        completion([final copy]);
    });
    
}


-(void) requestWithPath:(NSString*) path andParams:(NSDictionary*)parameters withTimeout:(int) timeout completion:(void (^)(NSArray *))completion {
    
    // aggiungo l'estensione
    NSString *phpFile = path;
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
                                                        NSLog(@"Response: %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
                                                        if (httpResp.statusCode == 200) {
                                                            NSError *jsonParsingError = nil;
                                                            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
                                                            
                                                            if(!jsonParsingError) {
                                                                
                                                                    NSString *status = [jsonDict objectForKey:@"status"];
                                                                    // se non ho errore nello status passo l'object response
                                                                    if(![status isEqualToString:@"error"]) {
                                                                        TRC_DBG(@"%@ --> %@",phpFile,status);
                                                                        completion([jsonDict objectForKey:@"response"]);
                                                                    }
                                                                    else TRC_ALT(@"Response status for %@ error: %@",phpFile,jsonDict);
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

-(void) genericJSONRequestWithURL:(NSString*)urlString withTimeout:(int) timeout completion:(void (^)(NSArray*))completion {
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    [defaultConfigObject setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setTimeoutInterval:timeout];
    
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    
                                                    
                                                    if (!error) {
                                                        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                                        
                                                        if (httpResp.statusCode == 200) {
                                                            NSError *jsonParsingError = nil;
                                                            NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                //[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                            });
                                                            if(!jsonParsingError) completion(jsonArray);
                                                            //else  NSLog(@"Bad Server JSON: %@",httpResp); // chissene frega, non è il mio server che risponde
                                                            
                                                        } else {
                                                            // HANDLE BAD RESPONSE //
                                                            TRC_ERR(@"Bad Server response: %@",httpResp);
                                                        }
                                                    } else {
                                                        // HANDLE ERROR //
                                                        TRC_ERR(@"Error with the request %@",error);
                                                    }
                                                    
                                                }];
    
    
    [dataTask resume];

    
}


-(void) downloadDataWithURL:(NSString*)urlString withTimeout:(int) timeout completion:(void (^)(NSData*))completion {
    
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
   // [defaultConfigObject setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setTimeoutInterval:timeout];
    
    
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
                                                            //else  NSLog(@"Bad Server JSON: %@",httpResp); // chissene frega, non è il mio server che risponde
                                                            
                                                        } else {
                                                            // HANDLE BAD RESPONSE //
                                                            TRC_ERR(@"Bad Server response: %@",httpResp);
                                                        }
                                                    } else {
                                                        // HANDLE ERROR //
                                                        TRC_ERR(@"Error with the request %@",error);
                                                    }
                                                    
                                                }];
    
    
    [dataTask resume];
    
    
}

@end
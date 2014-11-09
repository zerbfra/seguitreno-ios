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
                                                            
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                                                            });
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


/*
 +(APIClient *)sharedClient {
 static APIClient *_sharedClient = nil;
 static dispatch_once_t oncePredicate;
 dispatch_once(&oncePredicate, ^{
 _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:BaseURLString]];
 
 });
 return _sharedClient;
 }
 
 -(id)initWithBaseURL:(NSURL *)url {
 self = [super initWithBaseURL:url];
 if (!self) {
 return nil;
 }
 //[self registerHTTPOperationClass:[AFJSONRequestOperation class]];
 //[self setDefaultHeader:@"Accept" value:@"application/json"];
 //self.parameterEncoding = AFJSONParameterEncoding;
 
 return self;
 
 }
 */

/*

// Esegue la richiesta e ritorna un operation
-(AFHTTPRequestOperation *) executeRequestWithPath:(NSString*) path andParams:(NSDictionary*) parameters {
    
    // normalmente richiamo il metodo con 20 di timeout
    return [self executeRequestWithPath:path andParams:parameters withTimeout:20];
    
}

-(AFHTTPRequestOperation *) executeRequestWithPath:(NSString*) path andParams:(NSDictionary*) parameters withTimeout:(int) timeout {
    
    // aggiungo l'estensione
    path = [path stringByAppendingString:@".php"];
    
    APIClient *client = [APIClient sharedClient];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    
    // post request
    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:path parameters:parameters];
    [request setTimeoutInterval:timeout];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    
    return operation;
    
}

// Disattiva indicatore di attività decrementando le attività
-(void) endRequest {
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
}
*/

@end
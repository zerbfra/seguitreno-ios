//
//  APIClient.h
//  PriceRadar
//
//  Created by Francesco Zerbinati on 30/03/14.
//  Copyright (c) 2014 Francesco. All rights reserved.
//


/******* UTILIZZO ******************
 
 AFHTTPRequestOperation *operation = [[APIClient sharedClient] executeRequestWithPath:@"removeItem" andParams:@{@"uuid":storedUUID,@"id":c.id_amazon,@"store":c.store}] ;
 
 [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    // Print the response body in text
    NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
    [[APIClient sharedClient] endRequest];
 
 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"Error: %@", error);
    [[APIClient sharedClient] endRequest];
 }];
 
 [operation start];
 
//// PER FETCHARE IL JSON IN ARRIVO
 
 [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil]
 
*****************************************/



@interface APIClient : NSObject  //: AFHTTPClient

+(APIClient *)sharedClient;

-(void) requestWithPath:(NSString*) path andParams:(NSDictionary*)parameters completion:(void (^)(NSDictionary *))completion;
-(void) requestWithPath:(NSString*) path andParams:(NSDictionary*)parameters withTimeout:(int) timeout cacheLife:(int) life completion:(void (^)(NSDictionary *))completion;

//-(void) genericJSONRequestWithURL:(NSString*)urlString withTimeout:(int) timeout completion:(void (^)(NSArray *))completion;

//-(void) downloadDataWithURL:(NSString*)urlString withTimeout:(int) timeout completion:(void (^)(NSData*))completion;

//-(void) requestGroup:(NSMutableArray*) batch completion:(void (^)(NSArray *))completion;


@end
//
//  APIClient.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 30/11/14.
//  Copyright (c) 2014 Francesco. All rights reserved.
//



@interface APIClient : NSObject

+(APIClient *)sharedClient;

-(void) requestWithPath:(NSString*) path andParams:(NSDictionary*)parameters completion:(void (^)(NSDictionary *))completion;
-(void) requestWithPath:(NSString*) path andParams:(NSDictionary*)parameters withTimeout:(int) timeout cacheLife:(int) life completion:(void (^)(NSDictionary *))completion;



@end
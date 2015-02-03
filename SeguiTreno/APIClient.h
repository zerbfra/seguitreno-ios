//
//  APIClient.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 30/11/14.
//  Copyright (c) 2014 Francesco. All rights reserved.
//

@interface APIClient : NSObject

// singleton
+(APIClient *)sharedClient;

// richiesta remota di default
 // di default timeout 20s e vita della cache di 3 minuti
-(void) requestWithPath:(NSString*) path andParams:(NSDictionary*)parameters completion:(void (^)(NSDictionary *))completion;

// richiesta remota specificando timeout, vita della cache
-(void) requestWithPath:(NSString*) path andParams:(NSDictionary*)parameters withTimeout:(int) timeout cacheLife:(int) life completion:(void (^)(NSDictionary *))completion;



@end
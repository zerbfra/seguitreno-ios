//
//  ThreadHelper.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 05/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreadHelper : NSObject

+(ThreadHelper *)shared;

// segue il metodo "taskMethod" in background
-(void) executeInBackground:(SEL)taskMethod of:(id)target completion:(void (^)(BOOL success))completionBlock;
// come sopra con parametri
-(void) executeInBackground:(SEL)taskMethod of:(id)target withParam:(id)param completion:(void (^)(BOOL success))completionBlock;



@end

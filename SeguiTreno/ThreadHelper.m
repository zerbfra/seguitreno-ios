//
//  ThreadHelper.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 05/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "ThreadHelper.h"

@implementation ThreadHelper

+(ThreadHelper *)shared {
    static ThreadHelper *_shared = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _shared = [[self alloc] init];
        
    });
    return _shared;
}

-(void) executeInBackground:(SEL)taskMethod of:(id)target completion:(void (^)(BOOL success))completionBlock {
    
    // porto in background il task
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // pragma per pulire il warning
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // ESEGUO il metodo
        [target performSelector:taskMethod];
        #pragma clang diagnostic pop
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // rimando al main thread --> completion
            completionBlock(TRUE);
        });
        
    });
    
    
}

-(void) executeInBackground:(SEL)taskMethod of:(id)target withParam:(id)param completion:(void (^)(BOOL success))completionBlock {
    // porto in background il task
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // pragma per pulire il warning
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        // eseguo il metodo
        [target performSelector:taskMethod withObject:param];
        #pragma clang diagnostic pop
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // rimando al main thread --> completion
            completionBlock(TRUE);
        });
        
    });
}

@end

//
//  DBHelper.m
//  PriceRadar
//
//  Created by Francesco Zerbinati on 14/04/14.
//  Copyright (c) 2014 Francesco. All rights reserved.
//

#import "DBHelper.h"

@implementation DBHelper

+ (DBHelper *)sharedInstance {
    static dispatch_once_t once;
    static DBHelper * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] initWithQueue];
        
    });
    return sharedInstance;
}

- (id)initWithQueue {
    
    if ((self = [super init])) {
        NSString *libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *dbPath = [libDir   stringByAppendingPathComponent:@"seguitreno.db"];
        self.queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    
    return self;
}



-(NSMutableArray*) executeSQLStatement:(NSString*)stmt {
    
    __block NSMutableArray *results = [NSMutableArray array];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        if ([stmt rangeOfString:@"SELECT"].location == NSNotFound) [db executeUpdate:stmt];
        else {
            FMResultSet *rs = [db executeQuery:stmt];
            while ([rs next]) {
                [results addObject:[rs resultDictionary]];
            }
        }
    }];

    return results;
    
}

- (NSString*) dayFromNumber:(NSInteger) num {
    NSArray *week = @[@"lun",@"mar",@"mer",@"gio",@"ven",@"sab",@"dom"];
    return week[num];
    
}


@end

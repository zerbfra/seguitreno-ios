//
//  DBHelper.h
//  PriceRadar
//
//  Created by Francesco Zerbinati on 14/04/14.
//  Copyright (c) 2014 Francesco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBHelper : NSObject

@property (nonatomic,strong) FMDatabaseQueue *queue;

+ (DBHelper *)sharedInstance;


-(NSMutableArray*) executeSQLStatement:(NSString*)stmt;

- (NSString*) dayFromNumber:(NSInteger) num;

-(NSData*) getDatabaseBackup;
-(void) importBackup:(NSData*) data;
-(NSArray*) createDBForSync;

@end

//
//  DBHelper.m
//  SeguiTreno
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

// esegue statement multipli (viene usato dalle procedure di backup)
-(void) executeMultipleStatements:(NSString*)sql {
    
    [self.queue inDatabase:^(FMDatabase *db) {
        [db executeStatements:sql];
    }];
    
}



-(NSData*) getDatabaseBackup {
    NSData *backup;
    
    NSArray *treni = [[DBHelper sharedInstance] executeSQLStatement:@"SELECT * FROM treni"];
    NSArray *ripetizioni = [[DBHelper sharedInstance] executeSQLStatement:@"SELECT * FROM ripetizioni"];
    NSArray *treniviaggi = [[DBHelper sharedInstance] executeSQLStatement:@"SELECT * FROM 'treni-viaggi'"];
    NSArray *viaggi = [[DBHelper sharedInstance] executeSQLStatement:@"SELECT * FROM viaggi"];
    
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:treni,@"treni",ripetizioni,@"ripetizioni",treniviaggi,@"treniviaggi",viaggi,@"viaggi",nil];
    
    backup = [NSKeyedArchiver archivedDataWithRootObject:result];

    
    return backup;
}

-(void) importBackup:(NSData *)data {
    
    NSLog(@"Importazione backup in corso...");

    // azzero il db attuale
    NSString *deleteQuery = @"DELETE FROM viaggi; DELETE FROM ripetizioni; DELETE FROM treni; DELETE FROM 'treni-viaggi'; VACUUM;";
    [[DBHelper sharedInstance] executeMultipleStatements:deleteQuery];
    
    NSDictionary *backup = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSArray *viaggi = [backup objectForKey:@"viaggi"];
    NSArray *ripetizioni = [backup objectForKey:@"ripetizioni"];
    NSArray *treni = [backup objectForKey:@"treni"];
    NSArray *treniviaggi = [backup objectForKey:@"treniviaggi"];
    
    
    NSMutableString *query = [NSMutableString string];
    
    
    // viaggi
    for(int idx = 0; idx < [viaggi count]; idx++) {
        NSDictionary *backupViaggio = [viaggi objectAtIndex:idx];
        
        NSString *thisQuery = [NSString stringWithFormat:@"INSERT INTO viaggi (nomePartenza,nomeArrivo, orarioPartenza,orarioArrivo,durata) VALUES ('%@','%@','%@','%@','%@');",
                            [backupViaggio objectForKey:@"nomePartenza"],[backupViaggio objectForKey:@"nomeArrivo"],[backupViaggio objectForKey:@"orarioPartenza"],[backupViaggio objectForKey:@"orarioArrivo"],[backupViaggio objectForKey:@"durata"]];
        [query appendString:thisQuery];
    }

    [[DBHelper sharedInstance] executeMultipleStatements:query];

    
    [query setString:@""];
    
    //ripetizioni
    for(int idx = 0; idx < [ripetizioni count]; idx++) {
        NSDictionary *backupRipetizioni = [ripetizioni objectAtIndex:idx];
        
        NSString *thisQuery = [NSString stringWithFormat:@"INSERT INTO ripetizioni (id,idViaggio) VALUES ('%@','%@');",[backupRipetizioni objectForKey:@"id"],[backupRipetizioni objectForKey:@"idViaggio"]];
        [query appendString:thisQuery];
    }
    
    [[DBHelper sharedInstance] executeMultipleStatements:query];
    
    [query setString:@""];
    
    //treni
    for(int idx = 0; idx < [treni count]; idx++) {
        NSDictionary *backupTreni = [treni objectAtIndex:idx];
        
        NSString *thisQuery = [NSString stringWithFormat:@"INSERT INTO treni (numero,idOrigine,idDestinazione,categoria,nomePartenza,nomeArrivo,orarioPartenza,orarioArrivo) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@');",
                               [backupTreni objectForKey:@"numero"],[backupTreni objectForKey:@"idOrigine"],[backupTreni objectForKey:@"idDestinazione"],[backupTreni objectForKey:@"categoria"],[backupTreni objectForKey:@"nomePartenza"],[backupTreni objectForKey:@"nomeArrivo"],[backupTreni objectForKey:@"orarioPartenza"],[backupTreni objectForKey:@"orarioArrivo"]];

        [query appendString:thisQuery];
    }
    
    [[DBHelper sharedInstance] executeMultipleStatements:query];
    
    
    [query setString:@""];
    
    //treni-viaggi
    for(int idx = 0; idx < [treniviaggi count]; idx++) {
        NSDictionary *backupTreniviaggi = [treniviaggi objectAtIndex:idx];

        NSString *thisQuery = [NSString stringWithFormat:@"INSERT INTO 'treni-viaggi' (idViaggio,idTreno) VALUES ('%@','%@');",[backupTreniviaggi objectForKey:@"idViaggio"] ,[backupTreniviaggi objectForKey:@"idTreno"]];
        [query appendString:thisQuery];
    }
    
    [[DBHelper sharedInstance] executeMultipleStatements:query];
    
}

// crea un array compatibile con json per l'invio al server dei treni dell'utente (per poterne poi gestire le notifiche con un cronjob sul server)
-(NSArray*) createDBForSync {
    
    NSMutableArray *dbTreni = [NSMutableArray array];

    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM viaggi"];
    
    NSArray *dbViaggi = [[DBHelper sharedInstance] executeSQLStatement:query];
    
    
    for (NSDictionary* viaggoSet in dbViaggi) {
        Viaggio *viaggio = [[Viaggio alloc] init];
        viaggio.idViaggio = [viaggoSet objectForKey:@"id"];
        viaggio.data = [[DateUtils shared] dateFrom:[[viaggoSet objectForKey:@"orarioPartenza"] intValue]];
        
        NSString*stmt = [NSString stringWithFormat:@"SELECT * FROM treni WHERE id IN (SELECT idTreno FROM 'treni-viaggi' WHERE idViaggio = '%@') ORDER BY orarioPartenza",viaggio.idViaggio];
        NSArray *treni = [[DBHelper sharedInstance] executeSQLStatement:stmt];
        if([treni count] > 0) {
            
            
            for (NSDictionary* trenoSet in treni) {
                
                
                NSMutableDictionary *trovato = [NSMutableDictionary dictionary];
                
                [trovato setObject:[trenoSet objectForKey:@"numero"] forKey:@"numero"];

                
                [trovato setObject:[trenoSet objectForKey:@"idOrigine"] forKey:@"origine"];
                

                
                NSDate *dataPartenza = [[DateUtils shared] dateFrom:[[trenoSet objectForKey:@"orarioPartenza"] intValue]];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:dataPartenza];
                NSInteger hour = [components hour];
                NSInteger minute = [components minute];
                
                NSDate* data = [[DateUtils shared] date:viaggio.data  At:hour min:minute];
                NSNumber *dataInt = [NSNumber numberWithInt:[[DateUtils shared] timestampFrom:data]];
                [trovato setObject:dataInt forKey:@"data"];
                
                
                [dbTreni addObject:trovato];
                
            }
        }
    }

    return dbTreni;
    
    
    
 
}

@end

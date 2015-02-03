//
//  DBHelper.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 14/04/14.
//  Copyright (c) 2014 Francesco. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBHelper : NSObject

@property (nonatomic,strong) FMDatabaseQueue *queue;

+ (DBHelper *)sharedInstance;

// esegue un istruzione SQL
-(NSMutableArray*) executeSQLStatement:(NSString*)stmt;


// DROPBOX: crea un NSData contente i treni come backup da mandare a dropbox
-(NSData*) getDatabaseBackup;

// DROPBOX: importa un backup da dropbox, inserendo i vari dati nel database
-(void) importBackup:(NSData*) data;

// SERVER: crea un array compatibile con json per l'invio al server dei treni dell'utente (per poterne poi gestire le notifiche con un cronjob sul server)
-(NSArray*) createDBForSync;

@end

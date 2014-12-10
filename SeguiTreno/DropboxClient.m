//
//  DropboxClient.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 10/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "DropboxClient.h"

@implementation DropboxClient

+ (DropboxClient *)shared {
    static dispatch_once_t once;
    static DropboxClient * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        
    });
    return sharedInstance;
}

/** Ritorna TRUE se dropbox è collegato */
-(BOOL) isDropboxLinked {
    DBAccountManager *manager = [DBAccountManager sharedManager];
    DBAccount *account = [manager linkedAccount];
    if(account) return TRUE;
    else return FALSE;
}

/* Setup del file system di dropbox */
-(void) setupDBFilesystem {
    
    if(![DBFilesystem sharedFilesystem]) {
        //Alloco DBFilesystem
        DBFilesystem *filesystem = [[DBFilesystem alloc] initWithAccount:[[DBAccountManager sharedManager] linkedAccount]];
        [DBFilesystem setSharedFilesystem:filesystem];
    }
}


-(DBAccountManager*) manageDropbox:(UIViewController*) viewController {
    
    DBAccountManager *manager = [DBAccountManager sharedManager];
    
    if([self isDropboxLinked]) {
        [[manager linkedAccount] unlink];
        [DBFilesystem setSharedFilesystem:nil];
    } else {
        [manager linkFromController:viewController];
    }
    
    
    return manager;
    
}


-(void) startTransfer:(NSString*) filePath isItADownlaod:(BOOL) isDownload andReplace:(BOOL) deleteOpt completion:(void (^)(void))completionBlock {
    
    // trasferimento su thread secondario
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [self setupDBFilesystem];
        
        if ([self isDropboxLinked]) {
            
            if(![[DBFilesystem sharedFilesystem] completedFirstSync]) {
                [[DBFilesystem sharedFilesystem] addObserver:self block:^{
                    if([[DBFilesystem sharedFilesystem] completedFirstSync]) {
                        NSLog(@"DBFilesystem ready");
                        [[DBFilesystem sharedFilesystem] removeObserver:self];
                        if(isDownload) [self download:filePath andReplace:deleteOpt];
                        else [self upload:filePath andReplace:deleteOpt];
                        
                    }
                    
                }];
            } else {
                if(isDownload) [self download:filePath andReplace:deleteOpt];
                else [self upload:filePath andReplace:deleteOpt];
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // rimando al main thread --> completion
            completionBlock();
        });
        
    });

    
}

/* Scarica e legge il file da dropbox */
-(void) download:(NSString*) path andReplace:(BOOL) replace {
    DBPath *existingPath = [[DBPath root] childPath:path];
    DBFileInfo *info = [[DBFilesystem sharedFilesystem] fileInfoForPath:existingPath error:nil];
    
    // controllo se è disponibile il file
    if(info) {
        
        DBFile *file = [[DBFilesystem sharedFilesystem] openFile:existingPath error:nil];
        NSData *contents = [file readData:nil];
#warning Attenzione qui sistemare
        // queste funzioni non devono stare nella classe di dropbox, devono essere passate con un completion!
        [[DBHelper sharedInstance] importBackup:contents];

        
        
    }
}

-(void) upload:(NSString*) path  andReplace:(BOOL) replace {
    
    DBPath *newPath = [[DBPath root] childPath:path];
    if(replace) [self deleteDropboxFile:newPath];
    [self createDropboxFile:newPath];

}

/* Cancella un file da dropbox */
-(void) deleteDropboxFile:(DBPath*) path {
    DBFileInfo *info = [[DBFilesystem sharedFilesystem] fileInfoForPath:path error:nil];
    if (info) [[DBFilesystem sharedFilesystem] deletePath:path error:nil]; // se il file esiste lo vado a cancellare
}

-(void) createDropboxFile:(DBPath*) path { //with data:(NSData*) data
    DBFile *file = [[DBFilesystem sharedFilesystem] createFile:path error:nil];
    NSData* backup = [[DBHelper sharedInstance] getDatabaseBackup];
    [file writeData:backup error:nil];
}




@end

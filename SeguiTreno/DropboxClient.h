//
//  DropboxClient.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 10/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>

@interface DropboxClient : NSObject

// singleton
+ (DropboxClient *)shared;

// ci dice se dropbox è collegato o meno
-(BOOL) isDropboxLinked;
// inizializza il filesystem dropbox
-(void) setupDBFilesystem;

// collega/scollega l'account dropbox
-(DBAccountManager*) manageDropbox:(UIViewController*) viewController;

// avvia il trasferimento che può essere un download o un upload, e può anche rimpiazzare il file precedente
-(void) startTransfer:(NSString*) filePath isItADownlaod:(BOOL) isDownload andReplace:(BOOL) deleteOpt completion:(void (^)(void))completionBlock;


@end

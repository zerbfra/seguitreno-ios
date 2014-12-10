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

+ (DropboxClient *)shared;

-(BOOL) isDropboxLinked;
-(void) setupDBFilesystem;

-(DBAccountManager*) manageDropbox:(UIViewController*) viewController;

-(void) startTransfer:(NSString*) filePath isItADownlaod:(BOOL) isDownload andReplace:(BOOL) deleteOpt completion:(void (^)(void))completionBlock;


@end

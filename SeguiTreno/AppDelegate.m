//
//  AppDelegate.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 05/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "AppDelegate.h"
#import <Dropbox/Dropbox.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self createCopyOfDatabaseIfNeeded];
    
    // Dropbox
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:@"wwj9wcfcb2rnptz" secret:@"28f9g22ggv00l2d"];
    [DBAccountManager setSharedManager:accountManager];
    
    // Cancello vecchi file salvati nella Documents directory
    [self emptyCache];

    
    return YES;
}

// Dropbox
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        NSLog(@"App linked successfully!");
        return YES;
    }
    return NO;
}

-(void) emptyCache {
    NSError *error;
    // Percorso della cartella Documents
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    // Percorso per il json cache
    NSString *jsonPath = [docDir stringByAppendingPathComponent:@"/json"];
    
    NSArray *filePathsArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:jsonPath  error:&error];
    
    for(int i=0;i<[filePathsArray count];i++)
    {
        NSString *path = [NSString stringWithFormat:@"%@/%@",jsonPath,[filePathsArray objectAtIndex:i]];
        NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        NSDate *creationDate = [fileAttribs objectForKey:NSFileCreationDate];
        NSTimeInterval secs = [creationDate timeIntervalSinceNow];
        
        int min = -secs/60;
        // cancello tutti i file con timestamp di più di 30 min fa
        if(min > 30) {
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            if (!success) NSLog(@"Errore svuotamento cache: %@", [error localizedDescription]);
            else NSLog(@"Cancellato file da cache");
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
#warning qui sincro col server dei treni
    // invio database dei treni al server (questo per poter notificare all'utente i vari ritardi in base ai suoi treni)
    [[DBHelper sharedInstance] createDBForSync];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Function to Create a writable copy of the bundled default database in the application Documents directory.
- (BOOL)createCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *appDBPath = [libDir stringByAppendingPathComponent:@"seguitreno.db"];
    
    success = [fileManager fileExistsAtPath:appDBPath];
    
    if (success){
        //db già copiato
        NSLog(@"DB già copiato");
        return success;
    }
    
    
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath =  [[NSBundle mainBundle] pathForResource:@"seguitreno" ofType:@"db"];
    
    success = [fileManager copyItemAtPath:defaultDBPath toPath:appDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    } else NSLog(@"DB Copied to documents in %@",appDBPath);
    
    return success;
}

@end

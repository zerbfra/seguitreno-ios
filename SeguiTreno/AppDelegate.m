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
    
    // crea la copia del database sul file system locale
    [self createCopyOfDatabaseIfNeeded];
    
    // Dropbox: inizializzo con le mie credenziali
    DBAccountManager *accountManager = [[DBAccountManager alloc] initWithAppKey:@"wwj9wcfcb2rnptz" secret:@"28f9g22ggv00l2d"];
    [DBAccountManager setSharedManager:accountManager];
    
    // Cancello vecchi file salvati nella Documents directory (file di cache scaduti)
    [self emptyCache];
    
    //registro per le notifiche push
    [self registerPushNotifications];
    
    //azzero eventuali badge
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    return YES;
}

// Avvia la registrazione per le notifiche, sia su iOS8 che inferiori
-(void) registerPushNotifications {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        // iOS 8
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

// Metodo di accettazione della notifica - utente ha autorizzato l'invio di notifiche
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Did Register for Remote Notifications");
    
    NSString *tokenString;
    // Preparo il token per la registrazione rimuovendo caratteri < > e spazi
    tokenString = [[[[deviceToken description]
                     stringByReplacingOccurrencesOfString:@"<"withString:@""]
                    stringByReplacingOccurrencesOfString:@">" withString:@""]
                   stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    
    UIDevice *dev = [UIDevice currentDevice];
    NSString *appVersion =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    // invio la registrazione dell'utente al server quando il token è stato elaborato
    if(deviceToken != nil) {
        
        [[APIClient sharedClient] requestWithPath:@"registraUtente" andParams:@{@"token":tokenString,@"appVersion":appVersion,@"deviceModel":dev.model,@"systemVersion":dev.systemVersion} withTimeout:10 cacheLife:0 completion:^(NSDictionary *response) {
            
            if([response objectForKey:@"id"] != nil) {
                NSString *userID = [response objectForKey:@"id"];
                NSLog(@"User ID: %@",userID);
                
                // procedo a salvare il token nuovo, su NSUSerDefaults
                [[NSUserDefaults standardUserDefaults] setObject: userID forKey: userIDKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else NSLog(@"Something went wrong with userID registration");
            
            
        }];
        
    }
    
    
}

// Metodo di non accettazione delle notifiche - utente ha rifiutato l'invio delle notifiche
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    UIDevice *dev = [UIDevice currentDevice];
    NSString *appVersion =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    // in questo caso l'utente ha scelto di non ricevere le notifiche - lo registro comunque per fornire un id utente ma non ho il token
    // il server si occupa di gestire la situazione nel caso un utente decida poi di abilitare le notifiche (verrà chiamato quindi il metodo didRegisterForRemoteNotificationsWithDeviceToken
    [[APIClient sharedClient] requestWithPath:@"registraUtente" andParams:@{@"token":@"",@"appVersion":appVersion,@"deviceModel":dev.model,@"systemVersion":dev.systemVersion} withTimeout:10 cacheLife:0 completion:^(NSDictionary *response) {
        
        if([response objectForKey:@"id"] != nil) {
            NSString *userID = [response objectForKey:@"id"];
            NSLog(@"User ID: %@",userID);
            
            // procedo a salvare il token nuovo
            [[NSUserDefaults standardUserDefaults] setObject: userID forKey: userIDKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else NSLog(@"Something went wrong with userID registration");
        
        
    }];
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // se l'app è attiva (in foreground) mostro un semplice alert, in caso contrario viene visualizzato il classico banner di iOS
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"%@",userInfo);
        
        NSDictionary* userInfoDict = [userInfo objectForKey:@"aps"];
        
        UIAlertView *notificationAlert = [[UIAlertView alloc] initWithTitle:[userInfoDict objectForKey:@"title"] message:[userInfoDict objectForKey:@"alert"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [notificationAlert show];
    }
    
    
}


// Metodo di Dropbox proprietario
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    DBAccount *account = [[DBAccountManager sharedManager] handleOpenURL:url];
    if (account) {
        NSLog(@"App linked successfully!");
        return YES;
    }
    return NO;
}

// metodo che vuota la cache, cancella la cache con vita maggiore a 30 minuti
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

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // invio database dei treni al server (questo per poter notificare all'utente i vari ritardi in base ai suoi treni)
    
    NSArray* dbTreni = [[DBHelper sharedInstance] createDBForSync];
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:userIDKey];
    NSLog(@"%@",userID);
    
    NSLog(@"%@",dbTreni);
    
    // faccio la richiesta
    [[APIClient sharedClient] requestWithPath:@"salvaDatabase" andParams:@{@"treni":dbTreni,@"idUtente":userID} completion:^(NSDictionary *response) {
        NSLog(@"Response: %@", response);
        
    }];
    
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

// Funzione per creare una copia scrivibile del databse nella directory Library, chiaramente al primo avvio
- (BOOL)createCopyOfDatabaseIfNeeded {
  
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *libDir = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *appDBPath = [libDir stringByAppendingPathComponent:@"seguitreno.db"];
    
    success = [fileManager fileExistsAtPath:appDBPath];
    
    // per prima cosa ne testo l'esistenza
    if (success){
        //db già copiato
        NSLog(@"DB già copiato");
        return success;
    }
    
    
    // Se non esiste, lo copio
    NSString *defaultDBPath =  [[NSBundle mainBundle] pathForResource:@"seguitreno" ofType:@"db"];
    
    success = [fileManager copyItemAtPath:defaultDBPath toPath:appDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    } else NSLog(@"DB Copied to documents in %@",appDBPath);
    
    return success;
}

@end

//
//  NotificheViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 17/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "NotificheViewController.h"

#define push5Key   @"push5"
#define push10Key  @"push10"
#define push15Key  @"push15"
#define push30Key  @"push30"

#define NSStringFromBOOL(aBOOL)    aBOOL? @"1" : @"0"

@interface NotificheViewController ()

@end

@implementation NotificheViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // recupero i dati dai defaults (non li ho messi nel db perchè non voglio farne il backup)
    self.push5 =  [[[NSUserDefaults standardUserDefaults] objectForKey:push5Key] boolValue];
    self.push10 = [[[NSUserDefaults standardUserDefaults] objectForKey:push10Key] boolValue];
    self.push15 = [[[NSUserDefaults standardUserDefaults] objectForKey:push15Key] boolValue];
    self.push30 = [[[NSUserDefaults standardUserDefaults] objectForKey:push30Key] boolValue];
    
    
}

// Aggiungo i vari checkmark se necessario
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL setCheck = 0;
    
    switch (indexPath.row) {
        case 0:
            if(self.push5) setCheck = 1;
            break;
        case 1:
            if(self.push10) setCheck = 1;
            break;
        case 2:
            if(self.push15) setCheck = 1;
            break;
        case 3:
            if(self.push30) setCheck = 1;
            break;
        default:
            break;
    }
    
    if(setCheck) cell.accessoryType = UITableViewCellAccessoryCheckmark;

   
}
// quando scompare la vista comunico al server le impostazioni push
-(void) viewDidDisappear:(BOOL)animated {
    // aggiorno impostazioni notifiche per l'utente sul server
    NSLog(@"Notifiche => 5: %d 10: %d 15: %d 30: %d",self.push5,self.push10,self.push15,self.push30);
    
    NSString *idUtente = [[NSUserDefaults standardUserDefaults] objectForKey:userIDKey];
    
    [[APIClient sharedClient] requestWithPath:@"setNotifiche" andParams:@{@"id":idUtente,@"push5":NSStringFromBOOL(self.push5),@"push10":NSStringFromBOOL(self.push10),@"push15":NSStringFromBOOL(self.push15),@"push30":NSStringFromBOOL(self.push30)} withTimeout:10 cacheLife:0 completion:^(NSDictionary *response){
        
        NSLog(@"impostazioni notifiche salvate sul server");
    }];

    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            self.push5 = !self.push5;
            [[NSUserDefaults standardUserDefaults] setObject: NSStringFromBOOL(self.push5) forKey: push5Key];
            break;
        case 1:
            self.push10 = !self.push10;
            [[NSUserDefaults standardUserDefaults] setObject: NSStringFromBOOL(self.push10) forKey: push10Key];
            break;
        case 2:
            self.push15 = !self.push15;
            [[NSUserDefaults standardUserDefaults] setObject: NSStringFromBOOL(self.push15) forKey: push15Key];
            break;
        case 3:
            self.push30 = !self.push30;
            [[NSUserDefaults standardUserDefaults] setObject: NSStringFromBOOL(self.push30) forKey: push30Key];
            break;
            
        default:
            break;
    }
    
    // aggiorno checkmark (tolgo/metto)
    if([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark) {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    } else {
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    }
    

    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


@end

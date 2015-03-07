//
//  NotificheViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 17/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "NotificheViewController.h"

#define pushInterval   @"pushInterval"

#define NSStringFromBOOL(aBOOL)    aBOOL? @"1" : @"0"

@interface NotificheViewController ()

@end

@implementation NotificheViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // recupero i dati dai defaults (non li ho messi nel db perchè non voglio farne il backup)
    self.push =  [[[NSUserDefaults standardUserDefaults] objectForKey:pushInterval] intValue];

    
    
}

// Aggiungo i vari checkmark se necessario
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL setCheck = 0;

    switch (indexPath.row) {
        case 0:
            if(self.push == 5) setCheck = 1;
            break;
        case 1:
            if(self.push == 10) setCheck = 1;
            break;
        case 2:
            if(self.push == 15) setCheck = 1;
            break;
        case 3:
            if(self.push == 30) setCheck = 1;
            break;
        default:
            break;
    }
    
    if(setCheck) cell.accessoryType = UITableViewCellAccessoryCheckmark;

   
}
// quando scompare la vista comunico al server le impostazioni push
-(void) viewDidDisappear:(BOOL)animated {
    // aggiorno impostazioni notifiche per l'utente sul server
    NSLog(@"Notifica %d",self.push);
    
    NSString *idUtente = [[NSUserDefaults standardUserDefaults] objectForKey:userIDKey];
    
    /*
    [[APIClient sharedClient] requestWithPath:@"setNotifiche" andParams:@{@"id":idUtente,@"push5":NSStringFromBOOL(self.push5),@"push10":NSStringFromBOOL(self.push10),@"push15":NSStringFromBOOL(self.push15),@"push30":NSStringFromBOOL(self.push30)} withTimeout:10 cacheLife:0 completion:^(NSDictionary *response){
        
        NSLog(@"impostazioni notifiche salvate sul server");
    }];*/

    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    switch (indexPath.row) {
        case 0:
            self.push = 5;
            break;
        case 1:
            self.push = 10;
            break;
        case 2:
            self.push = 15;
             break;
        case 3:
            self.push = 30;
            break;
            
        default:
            break;
    }
    
    // aggiorno checkmark (tolgo/metto)
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType != UITableViewCellAccessoryCheckmark) cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    
    for (UITableViewCell* cellNotSet in tableView.visibleCells) {
        if(cellNotSet != cell) {
            cellNotSet.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:self.push] forKey:pushInterval];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


@end

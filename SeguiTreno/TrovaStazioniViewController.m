//
//  TrovaStazioniViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 07/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "TrovaStazioniViewController.h"

@interface TrovaStazioniViewController ()

@end

@implementation TrovaStazioniViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // status bar bianca
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];

   
}

-(void) viewDidAppear:(BOOL)animated {

    [[LocationManager sharedInstance] startWithAuthType:LocationManageraAuthTypeWhenInUse
                                         filterDistance:kCLDistanceFilterNone
                                               accuracy:kCLLocationAccuracyThreeKilometers
                                        completionBlock:^(CLLocation *newLocation, Error error) {
                                            if (newLocation != nil) {
                                                NSLog(@"Ricevuta posizione: %f, %f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
                                                
                                                [[ThreadHelper shared] executeInBackground:@selector(elencoStazioniVicineA:) of:self withParam:newLocation completion:^(BOOL success) {
                                                    NSLog(@"Caricate stazioni vicine");
                                                    for(Stazione *trovata in self.stazioniVicine) {
                                                        NSLog(@"%@",trovata.nome);
                                                    }

                                                }];
                                                
                                            } else {
                                                NSLog(@"Found error");
                                            }
                                            [[LocationManager sharedInstance] stopUpdate];
                                        }];
    
}

-(void) elencoStazioniVicineA:(CLLocation *) currentLocation {
    
    NSArray* results  = [[DBHelper sharedInstance] executeSQLStatement:@"SELECT * FROM stazioni"];
    NSMutableArray *stazioni = [[NSMutableArray alloc] init];
    NSMutableArray *vicine = [[NSMutableArray alloc] init];
    
    for (NSDictionary* set in results) {
        Stazione *stazione = [[Stazione alloc] init];
        
        stazione.idStazione = [set objectForKey:@"id"];
        stazione.nome       = [set objectForKey:@"nome"];
        //[stazione formattaNome];
        stazione.lat       = [[set objectForKey:@"lat"] floatValue];
        stazione.lon       = [[set objectForKey:@"lon"] floatValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:stazione.lat longitude:stazione.lon];
        stazione.posizione = location;
        
        [stazioni addObject:stazione];
    }
    
    for (Stazione *temp in stazioni) {
        CLLocationDistance distance = [currentLocation distanceFromLocation:temp.posizione];
        //NSLog(@"%f",distance);
        //distanza minore di 10km
        if (distance < 10000) {
            temp.distanza = distance;
            [vicine addObject:temp];
            //NSLog(@"%@",temp.nome);
        }
    }
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"distanza" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sort];
    self.stazioniVicine = [vicine sortedArrayUsingDescriptors:sortDescriptors];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

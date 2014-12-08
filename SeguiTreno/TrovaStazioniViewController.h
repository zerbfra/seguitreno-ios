//
//  TrovaStazioniViewController.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 07/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DettaglioStazioneViewController.h"

@interface TrovaStazioniViewController : UIViewController <MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSArray *stazioniVicine;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

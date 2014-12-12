//
//  DettaglioStazioneViewController.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 27/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DettaglioStazioneViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate>

@property (strong,nonatomic) Stazione* stazione;

//@property (strong,nonatomic) NSMutableArray* treniArrivo;
//@property (strong,nonatomic) NSMutableArray* treniPartenza;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

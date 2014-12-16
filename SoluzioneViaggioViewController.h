//
//  SoluzioneViaggioViewController.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 07/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SoluzioneViaggioViewController : UITableViewController

@property (strong,nonatomic) NSMutableArray *soluzioniPossibili;

@property (strong,nonatomic) Viaggio *query;

@end

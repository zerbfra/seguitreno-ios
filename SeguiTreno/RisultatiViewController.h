//
//  RisultatiViewController.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 01/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RisultatoRicercaTableViewCell.h"
#import "DettaglioTrenoViewController.h"

@interface RisultatiViewController : UITableViewController

@property (strong,nonatomic) NSMutableArray *soluzioniPossibili;

@property (strong,nonatomic) Viaggio *query;

@property NSInteger fascia;

@end

//
//  RicercaViewController.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 01/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchStazioneViewController.h"
#import "RisultatiViewController.h"

@interface RicercaViewController : UITableViewController <SearchStazioneDelegate,UIActionSheetDelegate>

@property (strong,nonatomic) Viaggio *viaggio;
@property (weak, nonatomic) IBOutlet UITableViewCell *stazioneDestinazione;
@property (weak, nonatomic) IBOutlet UITableViewCell *stazionePartenza;
@property (weak, nonatomic) IBOutlet UISegmentedControl *fasciaOraria;
@property (weak, nonatomic) IBOutlet UITextField *numeroTreno;

- (IBAction)search:(id)sender;
- (IBAction)selezioneFascia:(id)sender;

@property (strong,nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

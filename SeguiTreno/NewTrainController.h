//
//  NewTrainController.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 05/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SearchStazioneViewController.h"
#import "SoluzioneViaggioViewController.h"
#import "DettaglioSoluzioneViewController.h"
#import "MultiSelectSegmentedControl.h"


@interface NewTrainController : UITableViewController <UIActionSheetDelegate,SearchStazioneDelegate,SoluzioneViaggioDelegate,MultiSelectSegmentedControlDelegate>

@property BOOL trenoCompilato;
@property BOOL presenzaMezziNonTreno;

@property NSInteger ripetizioneSel;

@property (strong,nonatomic) NSDate* dataIniziale;

@property (weak, nonatomic) IBOutlet UITableViewCell *stazionePartenza;
@property (weak, nonatomic) IBOutlet UITableViewCell *stazioneDestinazione;

@property (weak, nonatomic) IBOutlet UITableViewCell *dataViaggio;
@property (weak, nonatomic) IBOutlet UITableViewCell *soluzioneViaggio;

@property (weak, nonatomic) IBOutlet UIDatePicker *pickDataViaggio;

@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *selettoreRipetizione;


@property (strong,nonatomic) NSMutableArray *giorni;

- (IBAction)ridisegnaPicker:(id)sender;


//- (IBAction)selezioneRipetizione:(UISegmentedControl *)sender;

@property (strong,nonatomic) Viaggio *viaggio;


@end

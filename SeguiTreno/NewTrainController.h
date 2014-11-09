//
//  NewTrainController.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 05/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMDateSelectionViewController.h"
#import "MultiSelectSegmentedControl.h"

#import "SearchStazioneViewController.h"
#import "SoluzioneViaggioViewController.h"
#import "DettaglioSoluzioneViewController.h"


@interface NewTrainController : UITableViewController <RMDateSelectionViewControllerDelegate,UIActionSheetDelegate,MultiSelectSegmentedControlDelegate,SearchStazioneDelegate,SoluzioneViaggioDelegate>


@property (weak, nonatomic) IBOutlet UITableViewCell *stazionePartenza;
@property (weak, nonatomic) IBOutlet UITableViewCell *stazioneDestinazione;

@property (weak, nonatomic) IBOutlet UITableViewCell *dataViaggio;
@property (weak, nonatomic) IBOutlet UITableViewCell *soluzioneViaggio;

@property (weak, nonatomic) IBOutlet UITableViewCell *ripeti;
@property (weak, nonatomic) IBOutlet UITableViewCell *inizioRipetizione;
@property (weak, nonatomic) IBOutlet UITableViewCell *fineRipetizione;

@property (weak, nonatomic) IBOutlet MultiSelectSegmentedControl *settimanaRipetizioni;

@property (strong,nonatomic)    Viaggio     *viaggio;

@property (strong,nonatomic)    Treno       *treno;

@property (nonatomic) BOOL refresh;

@end

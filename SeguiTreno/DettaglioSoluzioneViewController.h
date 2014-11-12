//
//  DettaglioSoluzioneViewController.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 08/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SoluzioneViaggioDelegate <NSObject>
- (void) impostaSoluzione:(Viaggio *) soluzioneSelezionata;
@end

@interface DettaglioSoluzioneViewController : UITableViewController

@property (nonatomic,strong) Viaggio *soluzione;

@property (weak, nonatomic) IBOutlet UILabel *orarioP;
@property (weak, nonatomic) IBOutlet UILabel *orarioA;

@property (weak, nonatomic) IBOutlet UILabel *stazioneP;
@property (weak, nonatomic) IBOutlet UILabel *stazioneA;

@property (weak, nonatomic) IBOutlet UILabel *numeroCambi;
@property (weak, nonatomic) IBOutlet UILabel *durataSoluzione;


@property (weak, nonatomic) id <SoluzioneViaggioDelegate> delegate;

@end

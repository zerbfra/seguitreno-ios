//
//  SoluzioneTableViewCell.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 07/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoluzioneTableViewCell : UITableViewCell

@property (strong,nonatomic) Viaggio *soluzione;

@property (weak, nonatomic) IBOutlet UILabel *orarioP;
@property (weak, nonatomic) IBOutlet UILabel *orarioA;

@property (weak, nonatomic) IBOutlet UILabel *stazioneP;
@property (weak, nonatomic) IBOutlet UILabel *stazioneA;

@property (weak, nonatomic) IBOutlet UILabel *soluzioneTreno;
@property (weak, nonatomic) IBOutlet UILabel *durataTreno;

-(void) disegna;

- (IBAction)vediDettaglio:(id)sender;
- (IBAction)seleziona:(id)sender;

@end

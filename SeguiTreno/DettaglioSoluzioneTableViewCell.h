//
//  DettaglioSoluzioneTableViewCell.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 09/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DettaglioSoluzioneTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *orarioP;
@property (weak, nonatomic) IBOutlet UILabel *orarioA;

@property (weak, nonatomic) IBOutlet UILabel *stazioneP;
@property (weak, nonatomic) IBOutlet UILabel *stazioneA;

@property Treno* treno;

@end

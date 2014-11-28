//
//  TrenoStazioneTableViewCell.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 28/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "TrenoStazioneTableViewCell.h"

@implementation TrenoStazioneTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void) setRitardo:(NSInteger) ritardo {
    self.status.layer.cornerRadius = 4;
    if(ritardo >= 30) self.status.backgroundColor = RED;
    if(ritardo > 0 && ritardo < 30) self.status.backgroundColor = [UIColor orangeColor];
    if(ritardo <= 0) self.status.backgroundColor = GREEN;
    
}

@end

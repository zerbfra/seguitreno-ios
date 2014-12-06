//
//  ScioperoTableViewCell.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "ScioperoTableViewCell.h"

@implementation ScioperoTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) disegna {
    self.titolo.text = self.sciopero.titolo;
    self.descrizione.text = self.sciopero.testo;
}

@end

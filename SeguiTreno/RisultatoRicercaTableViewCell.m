//
//  RisultatoRicercaTableViewCell.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 01/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "RisultatoRicercaTableViewCell.h"

@implementation RisultatoRicercaTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) disegna {
    
    self.partenza.text = self.soluzione.partenza.nome;
    self.arrivo.text = self.soluzione.arrivo.nome;

    
    self.orarioP.text = [[DateUtils shared] showHHmm:[self.soluzione orarioPartenza]];
    self.orarioA.text = [[DateUtils shared] showHHmm:[self.soluzione orarioArrivo]];
    
    Treno *primo = self.soluzione.tragitto[0];
    self.treno.text = [primo stringaDescrizione];
        
    
}


@end

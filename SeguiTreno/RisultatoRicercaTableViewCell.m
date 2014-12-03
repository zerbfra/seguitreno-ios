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
    
    self.partenza.text = self.treno.origine.nome;
    self.arrivo.text = self.treno.destinazione.nome;

    
    self.orarioP.text = [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:self.treno.orarioPartenza]];
    self.orarioA.text = [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:self.treno.orarioArrivo]];
    

    self.descTreno.text = [self.treno stringaDescrizione];
        
    
}


@end

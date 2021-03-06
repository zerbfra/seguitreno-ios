//
//  SoluzioneTableViewCell.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 07/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "SoluzioneTableViewCell.h"

@implementation SoluzioneTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

// disegna la cella
-(void) disegna {
    
    self.durataTreno.text = self.soluzione.durata;
    self.stazioneP.text = self.soluzione.partenza.nome;
    self.stazioneA.text = self.soluzione.arrivo.nome;
    
    NSUInteger cambi = [self.soluzione numeroCambi];

    self.orarioP.text = [[DateUtils shared] showHHmm:[self.soluzione orarioPartenza]];
    self.orarioA.text = [[DateUtils shared] showHHmm:[self.soluzione orarioArrivo]];
    
    if(cambi == 0) {
        // nessun cambio
        Treno *primo = self.soluzione.tragitto[0];
        self.soluzioneTreno.text = [NSString stringWithFormat:@"%@ %@",primo.categoria,primo.numero ];
        
    } else {
        if(cambi == 1) self.soluzioneTreno.text = [NSString stringWithFormat:@"Soluzione con %lu cambio",(unsigned long)cambi];
        else self.soluzioneTreno.text = [NSString stringWithFormat:@"Soluzione con %ld cambi",(long)cambi];

    }
    
}



@end

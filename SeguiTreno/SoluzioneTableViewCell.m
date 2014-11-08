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

    // Configure the view for the selected state
}

- (IBAction)vediDettaglio:(id)sender {
}

- (IBAction)seleziona:(id)sender {
}

-(void) disegna {
    
    self.durataTreno.text = self.soluzione.durata;
    self.stazioneP.text = self.soluzione.origine.nome;
    self.stazioneA.text = self.soluzione.destinazione.nome;
    
    NSUInteger cambi = [self.soluzione.tragitto count]-1;
    
    self.orarioP.text = [self formattaTimestamp:[self.soluzione.tragitto[0] objectForKey:@"orarioPartenza"]];
    self.orarioA.text = [self formattaTimestamp:[self.soluzione.tragitto[cambi] objectForKey:@"orarioArrivo"]];
    
    if(cambi == 0) {
        // nessun cambio
    
        self.soluzioneTreno.text = [self.soluzione.tragitto[0] objectForKey:@"numero"];
        NSLog(@"%@",self.soluzione.origine.nome);
        if([[self.soluzione.tragitto[0] objectForKey:@"categoria"] isEqualToString:@""]) {
            self.soluzioneTreno.text = [NSString stringWithFormat:@"%@ %@",@"REG",[self.soluzione.tragitto[0] objectForKey:@"numero"]];
        } else {
            self.soluzioneTreno.text = [NSString stringWithFormat:@"%@ %@",[self.soluzione.tragitto[0] objectForKey:@"categoria"],[self.soluzione.tragitto[0] objectForKey:@"numero"]];
        }
        
    } else {
        
        
        if(cambi == 1) self.soluzioneTreno.text = [NSString stringWithFormat:@"Soluzione con %lu cambio",cambi] ;
        else self.soluzioneTreno.text = [NSString stringWithFormat:@"Soluzione con %lu cambi",cambi] ;
        
        
        
    }
    
}

-(NSString*) formattaTimestamp:(NSString*) ts {
    NSTimeInterval _interval = [ts doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    
    NSString *dateString = [timeFormatter stringFromDate: date];
    
    return dateString;
}


@end

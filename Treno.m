//
//  Treno.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "Treno.h"
#import <objc/runtime.h>

@implementation Treno

@synthesize categoria = _categoria;

-(void) setCategoria:(NSString *)categoria {
    
    if([categoria isEqualToString:@""]) {
        _categoria = @"REG";
    } else {
        _categoria = categoria;
    }
}


-(NSDate*) dataPartenza   {

    NSDate *partenza = [NSDate dateWithTimeIntervalSince1970:self.orarioPartenza];
    return partenza;
}

-(NSDate*) dataArrivo {

    NSDate *arrivo = [NSDate dateWithTimeIntervalSince1970:self.orarioArrivo];
    return arrivo;
}

-(NSString*) mostraOrario:(NSDate*) date {
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    
    NSString *dateString = [timeFormatter stringFromDate: date];
    
    return dateString;
}

-(NSString*) mostraData:(NSDate*) date {
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    
    [timeFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *dateString = [timeFormatter stringFromDate: date];
    
    return dateString;
}

-(NSString*) stringaStatoTemporale {
    
    if(!self.soppresso && !self.arrivato) {
        // se non soprresso e non arrivato
        return [self stringaRitardo];
    } else {
        if(self.soppresso) return @"SOPPRESSO";
        if(self.arrivato)  return @"ARRIVATO";
    }
    
    return @"--";
    
}

-(NSString*) stringaRitardo {
    int ritardo = abs((int)self.ritardo);
    

    
    if(self.soppresso) return @"SOPPRESSO";
    
    if(self.nonDisponibile) return @"NON DISPONIBILE";
    if([self.stazioneUltimoRilevamento isEqualToString:@"--"]) return @"NON ANCORA PARTITO";
    
    
    if(self.ritardo < 0) return [NSString stringWithFormat:@"ANTICIPO %d MIN",ritardo];
    if(self.ritardo > 0) return [NSString stringWithFormat:@"RITARDO %d MIN",ritardo];
    if(self.ritardo == 0) return @"IN ORARIO";
    
    return @"";

}

-(NSString*) stringaDescrizione {
    return [NSString stringWithFormat:@"%@ %@",self.categoria,self.numero];
}


// carica informazioni complete del treno
-(void) caricaInfoComplete:(void (^)(void))completionBlock {

    [[APIClient sharedClient] requestWithPath:@"trovaTreno" andParams:@{@"numero":self.numero,@"origine":self.origine.idStazione,@"includiFermate":[NSNumber numberWithBool:true]} completion:^(NSDictionary *response) {

        for(NSDictionary *trenoDict in response) {
            Stazione *origine = [[Stazione alloc] init];
            Stazione *destinazione = [[Stazione alloc] init];
            origine.idStazione = [trenoDict objectForKey:@"idOrigine"];
            origine.nome =  [trenoDict objectForKey:@"origine"];
            destinazione.idStazione = [trenoDict objectForKey:@"idDestinazione"];
            destinazione.nome =  [trenoDict objectForKey:@"destinazione"];
            [origine formattaNome];
            [destinazione formattaNome];
            self.origine = origine;
            self.destinazione = destinazione;
            self.categoria = [trenoDict objectForKey:@"categoria"];
            self.stazioneUltimoRilevamento = [trenoDict objectForKey:@"stazioneUltimoRilevamento"];
            self.oraUltimoRilevamento = [trenoDict objectForKey:@"oraUltimoRilevamento"];
            
            self.orarioArrivo = [[trenoDict objectForKey:@"orarioArrivo"] doubleValue];
            self.orarioPartenza = [[trenoDict objectForKey:@"orarioPartenza"] doubleValue];
            self.ritardo = [[trenoDict objectForKey:@"ritardo"] integerValue];
            
            self.arrivato = [[trenoDict objectForKey:@"arrivato"] boolValue];
            self.soppresso = [[trenoDict objectForKey:@"sopresso"] boolValue];
            
            NSDictionary *fermateDict = [trenoDict objectForKey:@"fermate"];
            
            NSMutableArray *fermateArray = [NSMutableArray array];
            
            for(NSDictionary *fermate in fermateDict) {
                
                
                Fermata *fermata = [[Fermata alloc] init];
                
                fermata.binarioEffettivo = [fermate objectForKey:@"binarioProgrammato"];
                fermata.binarioProgrammato = [fermate objectForKey:@"binarioEffettivo"];
                
                if([fermata.binarioEffettivo isEqualToString:@""]) fermata.binarioEffettivo = nil;
                if([fermata.binarioProgrammato isEqualToString:@""]) fermata.binarioProgrammato = nil;
                
                fermata.orarioProgrammato = [[fermate objectForKey:@"programmata"] doubleValue];
                fermata.raggiunta = [[fermate objectForKey:@"raggiunta"] boolValue];
                
                fermata.orarioEffettivo = [[fermate objectForKey:@"effettiva"] doubleValue];
                
                fermata.progressivo = [[fermate objectForKey:@"progressivo"] intValue];
                
                
                if(fermata.raggiunta == true) {
                    fermata.orarioEffettivo = [[fermate objectForKey:@"effettiva"] doubleValue]; // caso i cui sia effettiva (e quindi treno arrivato li)
                }
                else  {
                    fermata.orarioEffettivo = fermata.orarioProgrammato +  self.ritardo*60; // caso in cui non cè effettiva, stimo l'orario con il ritardo
                    
                }
                
                
                
                NSDictionary *stazioneDict = [fermate objectForKey:@"stazione"];
                Stazione *stazFermata = [[Stazione alloc] init];
                stazFermata.idStazione = [stazioneDict objectForKey:@"id"];
                stazFermata.nome = [stazioneDict objectForKey:@"nome"];

                [stazFermata formattaNome];
                
                fermata.stazione = stazFermata;
                
                [fermateArray addObject:fermata];
                
            }
            
            self.fermate = fermateArray;
            
            
        }
        
        completionBlock();
        
        
        
    }];
    
}



@end

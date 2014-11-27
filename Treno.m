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
    
    if(self.nonDisponibile) return @"NON DISPONIBILE";
    
    if(self.ritardo < 0) return [NSString stringWithFormat:@"ANTICIPO %d MIN",ritardo];
    if(self.ritardo > 0) return [NSString stringWithFormat:@"RITARDO %d MIN",ritardo];
    if(self.ritardo == 0) return @"IN ORARIO";
    
    return @"";

}

-(NSString*) stringaDescrizione {
    return [NSString stringWithFormat:@"%@ %@",self.categoria,self.numero];
}


@end

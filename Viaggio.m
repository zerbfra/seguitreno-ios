//
//  Viaggio.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 07/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "Viaggio.h"

@implementation Viaggio

-(NSUInteger) numeroCambi {
    return [self.tragitto count]-1;
}

-(NSDate*) orarioPartenza {
    
    Treno *temp = self.tragitto[0];
    NSDate *partenza = [[DateUtils shared] dateFrom:temp.orarioPartenza];
    //NSDate *partenza = [NSDate dateWithTimeIntervalSince1970:temp.partenza.orarioPartenza];
    return partenza;
}

-(NSDate*) orarioArrivo {
    
    NSUInteger cambi = [self numeroCambi];
    
    Treno *temp = self.tragitto[cambi];
    NSDate *arrivo = [[DateUtils shared] dateFrom:temp.orarioArrivo];
    //NSDate *arrivo = [NSDate dateWithTimeIntervalSince1970:temp.arrivo.orarioArrivo];
    return arrivo;
}

-(NSArray*) jsonCompatibile {
    
    NSMutableArray *numeriTreno = [[NSMutableArray alloc] init];

    for(Treno* treno in self.tragitto) {
        
        [numeriTreno addObject:treno.numero];
    }
    
    return (NSArray*)numeriTreno;
}

-(NSString*) luogoPartenza {
    Treno *temp = self.tragitto[0];
    return temp.partenza.nome;
}

-(NSString*) luogoArrivo {
    NSUInteger cambi = [self numeroCambi];
    Treno *temp = self.tragitto[cambi];
    return temp.arrivo.nome;
}


@end

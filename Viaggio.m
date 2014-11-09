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
    //NSString *orarioPartenza = temp.orarioPartenza;
    //NSTimeInterval _interval = [orarioPartenza doubleValue];
    NSDate *partenza = [NSDate dateWithTimeIntervalSince1970:temp.orarioPartenza];
    return partenza;
}

-(NSDate*) orarioArrivo {
    
    NSUInteger cambi = [self numeroCambi];
    
    Treno *temp = self.tragitto[cambi];
    //NSString *orarioArrivo = [self.tragitto[cambi] objectForKey:@"orarioPartenza"];
    //NSTimeInterval _interval = [orarioArrivo doubleValue];
    NSDate *arrivo = [NSDate dateWithTimeIntervalSince1970:temp.orarioArrivo];
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

-(NSArray*) jsonCompatibile {
    
    NSMutableArray *numeriTreno = [[NSMutableArray alloc] init];

    for(Treno* treno in self.tragitto) {
        
        [numeriTreno addObject:treno.numero];
    }
    
    return (NSArray*)numeriTreno;
}

@end

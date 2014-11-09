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

-(NSDate*) datePartenza   {

    NSDate *partenza = [NSDate dateWithTimeIntervalSince1970:self.orarioPartenza];
    return partenza;
}

-(NSDate*) dateArrivo {

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



@end

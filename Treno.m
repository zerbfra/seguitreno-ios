//
//  Treno.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "Treno.h"

@implementation Treno

@synthesize categoria = _categoria;

-(void) setCategoria:(NSString *)categoria {
    
    if([categoria isEqualToString:@""]) {
        _categoria = @"REG";
    } else {
        _categoria = categoria;
    }
}

@end

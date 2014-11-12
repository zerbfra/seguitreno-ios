//
//  DateUtils.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 12/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "DateUtils.h"

@implementation DateUtils

+(DateUtils *)shared {
    static DateUtils *_shared = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _shared = [[self alloc] init];
        
    });
    return _shared;
}

-(NSDate*) dateFrom:(NSTimeInterval) ts {
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:ts];
    return date;
}



-(NSString*) showHHmm:(NSDate*) date {
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    
    NSString *dateString = [timeFormatter stringFromDate: date];
    
    return dateString;
}

-(NSString*) showDateAndHHmm:(NSDate*) date {
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    
    [timeFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *dateString = [timeFormatter stringFromDate: date];
    
    return dateString;
}

@end

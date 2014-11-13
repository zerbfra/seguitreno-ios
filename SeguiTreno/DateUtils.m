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


-(NSDate*) getNexWeekDateFor:(NSDate*) date until:(NSDate*) finish {
    
    NSDate *nextDate = [date dateByAddingTimeInterval:(7*24*3600)];
    //NSLog(@"%@",[[DateUtils shared] showDateAndHHmm:nextDate]);
    
    if ([nextDate compare:finish] == NSOrderedAscending) {
        // nextDate minore di finish
        return nextDate;
    } else {
        return nil;
    }
    
    
}

-(NSString*) showHHmm:(NSDate*) date {
    
    if(date == nil) date = [NSDate date];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    
    NSString *dateString = [timeFormatter stringFromDate: date];
    
    return dateString;
}

-(NSString*) showDateAndHHmm:(NSDate*) date {
    
    if(date == nil) date = [NSDate date];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    
    [timeFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *dateString = [timeFormatter stringFromDate: date];
    
    return dateString;
}

-(NSString*) showDateFull:(NSDate*) date {
    
    if(date == nil) date = [NSDate date];
    
    NSString *dateString;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateStyle:NSDateFormatterFullStyle];
    [format setTimeStyle:NSDateFormatterNoStyle];
    
    dateString = [format stringFromDate:date];
    
    return dateString;
}

-(NSString*) showDateMedium:(NSDate *)date {
    
    if(date == nil) date = [NSDate date];
    
    NSString *dateString;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateStyle:NSDateFormatterShortStyle];
    [format setTimeStyle:NSDateFormatterNoStyle];
    
    dateString = [format stringFromDate:date];
    
    return dateString;
}

-(NSString*) showDay:(NSDate*) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayName = [dateFormatter stringFromDate:date];
    return dayName;
}

@end

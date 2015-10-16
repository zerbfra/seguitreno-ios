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

-(NSTimeInterval) timestampFrom:(NSDate*) date {
    return [date timeIntervalSince1970];
}

-(NSDate*) getNexWeekDateFor:(NSDate*) date until:(NSDate*) finish {
    
    NSDate *nextDate = [date dateByAddingTimeInterval:(7*24*3600)];
    
    if ([nextDate compare:finish] == NSOrderedAscending || [nextDate compare:finish] == NSOrderedSame) {
        // nextDate minore di finish
        return nextDate;
    } else {
        return nil;
    }
    
    
}

-(NSArray*) arrayOfNextWeekDays:(NSInteger) weekday startingFrom:(NSDate*) today to:(NSDate*) end {
    
    NSMutableArray *nexts = [NSMutableArray array];
    
    //aggiungo oggi
    //[nexts addObject:today];
    
    NSDate *nextDate = [self dateForNextWeekday:weekday startingFrom:today];
    // finchè la nextdate è minore della fine vado avanti
    while ([nextDate compare:end] == NSOrderedAscending || [nextDate compare:end] == NSOrderedSame) {
        
        [nexts addObject:nextDate];
        
        nextDate = [self dateForNextWeekday:weekday startingFrom:nextDate];
    }
    
    
    return nexts;
}

- (NSDate *) dateForNextWeekday: (NSInteger)weekday startingFrom:(NSDate*)today {
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday
                                                       fromDate:today];
    
    /*
     Add components to get to the weekday we want
     */
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    NSInteger dif = weekday-weekdayComponents.weekday;
    if (dif<=0) dif += 7;
    [componentsToSubtract setDay:dif];
    
    NSDate *beginningOfWeek = [gregorian dateByAddingComponents:componentsToSubtract
                                                         toDate:today options:0];
    
    return beginningOfWeek;
}


-(NSDate*) addDays:(int) days toDate:(NSDate*) date {
    NSDate *nextDate = [date dateByAddingTimeInterval:days*24*3600];
    return nextDate;
}

- (int) daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return (int)[difference day];
}

- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
        return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
        return NO;
    
    return YES;
}

-(NSDate*) date:(NSDate*) date At:(NSInteger)hour min:(NSInteger)min {
    NSCalendar* myCalendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [myCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                 fromDate:date];
    [components setHour: hour];
    [components setMinute: min];
    [components setSecond: 0];
    NSDate *myDate = [myCalendar dateFromComponents:components];
    
    return myDate;
}

-(NSDate*) date:(NSDate*) date At:(NSInteger) hour {
    NSCalendar* myCalendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [myCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay
                                                 fromDate:date];
    [components setHour: hour];
    [components setMinute: 0];
    [components setSecond: 0];
    NSDate *myDate = [myCalendar dateFromComponents:components];
    
    return myDate;
}


/** Formattazione date **/

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
    
    [timeFormatter setDateStyle:NSDateFormatterShortStyle];
    
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

-(NSString*) getDayNumber:(NSDate*) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd"];
    NSString *dayName = [dateFormatter stringFromDate:date];
    return dayName;
}

-(NSString*) getMonthNumber:(NSDate*) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    NSString *dayName = [dateFormatter stringFromDate:date];
    return dayName;
}

-(NSString*) getYearNumber:(NSDate*) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *dayName = [dateFormatter stringFromDate:date];
    return dayName;
}

@end

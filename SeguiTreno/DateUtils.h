//
//  DateUtils.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 12/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

+(DateUtils *)shared;

// restituisce data da un nstimeinterval
-(NSDate*) dateFrom:(NSTimeInterval) ts;

// ottiene giorno della prossima settimana
-(NSDate*) getNexWeekDateFor:(NSDate*) date until:(NSDate*) finish;

// vedi solo ora
-(NSString*) showHHmm:(NSDate*) date;
// vedi data e ora
-(NSString*) showDateAndHHmm:(NSDate*) date;
// vedi stringa giorno settimana
-(NSString*) showDay:(NSDate*) date;
// vedi data intera (compresa di giorno settimana)
-(NSString*) showDateFull:(NSDate*) date;
// vedi data nel formato 10/11/2014
-(NSString*) showDateMedium:(NSDate*) date;

@end

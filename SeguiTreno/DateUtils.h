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

-(NSTimeInterval) timestampFrom:(NSDate*) date;

// restituisce un array di giorni della settimana (es: domenica = 1, sabato = 7) da una data all'altra
// ESEMPIO:     NSArray *prova = [[DateUtils shared] arrayOfNextWeekDays:1 startingFrom:[NSDate date] to:[[DateUtils shared] addDays:90 toDate:[NSDate date] ]];
-(NSArray*) arrayOfNextWeekDays:(NSInteger) weekday startingFrom:(NSDate*) today to:(NSDate*) end;


// ottiene giorno della prossima settimana corrispondente (es: lunedi --> lunedi settimana dopo)
// domenica = 1
// esempio:     NSDate *prova = [[DateUtils shared] dateForNextWeekday:2 startingFrom:[NSDate date]]; NSLog(@"%@",[[DateUtils shared] showDateFull:prova]);
-(NSDate*) getNexWeekDateFor:(NSDate*) date until:(NSDate*) finish;

// ottiene il prossimo lunedi/martedi/mercoledi... a partire dalla data today
- (NSDate *) dateForNextWeekday: (NSInteger)weekday startingFrom:(NSDate*)today;

// ritorna l'NSDate di una data ad un ora stabilita
-(NSDate*) date:(NSDate*) date At:(NSInteger) hour;
// con anche minuto
-(NSDate*) date:(NSDate*) date At:(NSInteger)hour min:(NSInteger)min;

// ritorna un bool che dice se la data è compresa tra altre due
- (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;

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

// ritorna la data che si ottiene aggiungendo n giorni ad una data di partenza
-(NSDate*) addDays:(int) days toDate:(NSDate*) date;

// ritorna i vari numeri (giorno,mese,anno) tipo: 25 02 2015:
-(NSString*) getDayNumber:(NSDate*) date;
-(NSString*) getMonthNumber:(NSDate*) date;
-(NSString*) getYearNumber:(NSDate*) date;

@end

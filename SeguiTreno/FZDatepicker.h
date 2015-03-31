//
//  FZDatePicker.h
//
//  Created by Francesco Zerbinati on 01/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//
//

#import <UIKit/UIKit.h>


extern const NSTimeInterval kSecondsInDay;
extern const CGFloat kFZDetepickerHeight;


@interface FZDatepicker : UIControl

// data
@property (strong, nonatomic) NSArray *dates;
@property (strong, nonatomic, readonly) NSDate *selectedDate;

// UI
@property (strong, nonatomic) UIColor *bottomLineColor;


// metodi
- (void)fillDatesFromCurrentDate:(NSInteger)nextDatesCount;

- (void) selectToday;
- (void)selectDate:(NSDate *)date;
- (void)selectDateAtIndex:(NSUInteger)index;

-(NSUInteger) selectedIndex;

@end

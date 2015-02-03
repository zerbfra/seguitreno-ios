//
//  FZDatePicker.h
//
//  Created by Francesco Zerbinati on 01/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//
//  Copyright (c) 2014 Dmitry Ivanenko. All rights reserved.
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
//@property (strong, nonatomic) UIColor *selectedDateBottomLineColor;

// methods
- (void)fillDatesFromCurrentDate:(NSInteger)nextDatesCount;
//- (void)fillDatesFromDate:(NSDate *)fromDate numberOfDays:(NSInteger)nextDatesCount;

- (void)selectDate:(NSDate *)date;
- (void)selectDateAtIndex:(NSUInteger)index;

-(NSUInteger) selectedIndex;

@end

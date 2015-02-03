//
//  FZDatePickerDateView.m
//
//  Created by Francesco Zerbinati on 01/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//
//  Copyright (c) 2014 Dmitry Ivanenko. All rights reserved.
//

#import "FZDatepickerDateView.h"


const CGFloat kFZDatepickerItemWidth = 46;
const CGFloat kFZDatepickerSelectionLineWidth = 51;

@interface FZDatepickerDateView ()

@end


@implementation FZDatepickerDateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    [self setupViews];

    return self;
}

- (void)setupViews
{

    self.selectionView.backgroundColor = COLOR_WITH_RGB(255,78,80);
    self.selectionView.alpha = 0;
    [self addTarget:self action:@selector(dateWasSelected) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setDate:(NSDate *)date
{
    _date = date;


    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:@"dd"];
    NSString *dayFormattedString = [dateFormatter stringFromDate:date];
    
    [dateFormatter setDateFormat:@"MMM"];
    NSString *monthFormattedString = [[dateFormatter stringFromDate:date] uppercaseString];

    [dateFormatter setDateFormat:@"EEEE"];
    NSString *dayInWeekFormattedString = [dateFormatter stringFromDate:date];



    NSMutableAttributedString *dateString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@\n%@", dayFormattedString, monthFormattedString, [dayInWeekFormattedString uppercaseString]]];

    [dateString addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:20],
                                NSForegroundColorAttributeName: [UIColor blackColor]
                                }
                        range:NSMakeRange(0, dayFormattedString.length)];

    if ([self isSunday:date]) {
        [dateString addAttributes:@{
                                    NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:8],
                                    NSForegroundColorAttributeName: COLOR_WITH_RGB(255,78,80)
                                    }
                            range:NSMakeRange(dayFormattedString.length + 1, monthFormattedString.length)];
        [dateString addAttributes:@{
                                    NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:20],
                                    NSForegroundColorAttributeName: COLOR_WITH_RGB(255,78,80)
                                    }
                            range:NSMakeRange(0, dayFormattedString.length)];
        
        
    } else {
        
        [dateString addAttributes:@{
                                    NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:8],
                                    NSForegroundColorAttributeName: [UIColor blackColor]
                                    }
                            range:NSMakeRange(dayFormattedString.length + 1, monthFormattedString.length)];
        
        [dateString addAttributes:@{
                                    NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Thin" size:20],
                                    NSForegroundColorAttributeName: [UIColor blackColor]
                                    }
                            range:NSMakeRange(0, dayFormattedString.length)];
        
    }


    [dateString addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:8],
                                NSForegroundColorAttributeName: COLOR_WITH_RGB(153, 153, 153)
                                }
                        range:NSMakeRange(dateString.string.length - dayInWeekFormattedString.length, dayInWeekFormattedString.length)];


    self.dateLabel.attributedText = dateString;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;
    
    // animo il cambio di selezione
    [UIView transitionWithView:self.selectionView
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^(void) {
                           self.selectionView.alpha = (int)_isSelected;
                    } completion:NULL];
}




#pragma mark    Altri metodi

- (BOOL)isSunday:(NSDate *)date
{
    NSInteger day = [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:date] weekday];

    BOOL isWeekdayResult = day == 1; //domenica

    return isWeekdayResult;
}

- (void)dateWasSelected
{
    self.isSelected = YES;

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark    UI 

- (UILabel *)dateLabel
{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _dateLabel.numberOfLines = 2;
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_dateLabel];
    }
    
    return _dateLabel;
}

- (UIView *)selectionView
{
    if (!_selectionView) {
        
        _selectionView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 51) / 2, self.frame.size.height - 3, 51, 3)];
        [self addSubview:_selectionView];
    }
    
    return _selectionView;
}

@end

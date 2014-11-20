//
//  Created by Dmitry Ivanenko on 15.04.14.
//  Copyright (c) 2014 Dmitry Ivanenko. All rights reserved.
//

#import "FZDatepickerDateView.h"


const CGFloat kFZDatepickerItemWidth = 46;
const CGFloat kFZDatepickerSelectionLineWidth = 51;


@interface FZDatepickerDateView ()

@property (strong, nonatomic) UILabel *dateLabel;
@property (nonatomic, strong) UIView *selectionView;

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
                                NSForegroundColorAttributeName: [UIColor colorWithRed:153./255. green:153./255. blue:153./255. alpha:1.]
                                }
                        range:NSMakeRange(dateString.string.length - dayInWeekFormattedString.length, dayInWeekFormattedString.length)];



    self.dateLabel.attributedText = dateString;
}

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected = isSelected;

    self.selectionView.alpha = (int)_isSelected;
}

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

- (void)setItemSelectionColor:(UIColor *)itemSelectionColor
{
    self.selectionView.backgroundColor = itemSelectionColor;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.selectionView.alpha = self.isSelected ? 1 : .5;
    } else {
        self.selectionView.alpha = self.isSelected ? 1 : 0;
    }
}


#pragma mark Other methods

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

@end

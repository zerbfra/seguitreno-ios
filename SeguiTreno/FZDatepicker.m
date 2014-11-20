//
//  Created by Dmitry Ivanenko on 14.04.14.
//  Copyright (c) 2014 Dmitry Ivanenko. All rights reserved.
//

#import "FZDatepicker.h"
#import "FZDatepickerDateView.h"


const NSTimeInterval kSecondsInDay = 86400;
const NSInteger kMondayOffset = 2;
const CGFloat kFZDatepickerHeight = 60;
const CGFloat kFZDatepickerSpaceBetweenItems = 15;


@interface FZDatepicker ()

@property (strong, nonatomic) UIScrollView *datesScrollView;

@end


@implementation FZDatepicker

- (void)awakeFromNib
{
    [self setupViews];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return self;

    [self setupViews];

    return self;
}

- (void)setupViews
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor whiteColor];
   
    self.selectedDateBottomLineColor = COLOR_WITH_RGB(255,78,80);
}


#pragma mark Setters | Getters

- (void)setDates:(NSArray *)dates
{
    _dates = dates;

    [self updateDatesView];

    self.selectedDate = nil;
}

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;

    for (id subview in self.datesScrollView.subviews) {
        if ([subview isKindOfClass:[FZDatepickerDateView class]]) {
            FZDatepickerDateView *dateView = (FZDatepickerDateView *)subview;
            dateView.isSelected = [dateView.date isEqualToDate:selectedDate];
        }
    }

    [self updateSelectedDatePosition];

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (UIScrollView *)datesScrollView
{
    if (!_datesScrollView) {
        _datesScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 60)];
        _datesScrollView.showsHorizontalScrollIndicator = NO;



        _datesScrollView.showsVerticalScrollIndicator = NO;
        _datesScrollView.autoresizingMask = self.autoresizingMask;
        [self addSubview:_datesScrollView];
    }
    return _datesScrollView;
}

- (void)setSelectedDateBottomLineColor:(UIColor *)selectedDateBottomLineColor
{
    _selectedDateBottomLineColor = selectedDateBottomLineColor;

    for (id subview in self.datesScrollView.subviews) {
        if ([subview isKindOfClass:[FZDatepickerDateView class]]) {
            FZDatepickerDateView *dateView = (FZDatepickerDateView *)subview;
            [dateView setItemSelectionColor:selectedDateBottomLineColor];
        }
    }
}


#pragma mark Public methods

- (void)fillDatesFromCurrentDate:(NSInteger)nextDatesCount
{
    NSAssert(nextDatesCount < 1000, @"Too much dates");

    NSMutableArray *dates = [[NSMutableArray alloc] init];
    for (NSInteger day = 0; day < nextDatesCount; day++) {
        [dates addObject:[NSDate dateWithTimeIntervalSinceNow:day * kSecondsInDay]];
    }

    self.dates = dates;
}

- (void)fillDatesFromDate:(NSDate *)fromDate numberOfDays:(NSInteger)nextDatesCount
{
    NSAssert(nextDatesCount < 1000, @"Too much dates");

    NSMutableArray *dates = [[NSMutableArray alloc] init];
    for (NSInteger day = 0; day < nextDatesCount; day++)
    {
        [dates addObject:[fromDate dateByAddingTimeInterval:day * kSecondsInDay]];
    }
    
    self.dates = dates;
}


- (void)selectDate:(NSDate *)date
{
    NSAssert([self.dates indexOfObject:date] != NSNotFound, @"Date not found in dates array");

    self.selectedDate = date;
}

- (void)selectDateAtIndex:(NSUInteger)index
{
    NSAssert(index < self.dates.count, @"Index too big");

    self.selectedDate = self.dates[index];
}


#pragma mark Private methods

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    // draw bottom line
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, COLOR_WITH_RGB(210,209,213).CGColor);
    CGContextSetLineWidth(context, 0.5f);
    CGContextMoveToPoint(context, 0, rect.size.height - .5);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height - .5);
    CGContextStrokePath(context);
 
 
}

- (void)updateDatesView
{
    [self.datesScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGFloat currentItemXPosition = kFZDatepickerSpaceBetweenItems;
    for (NSDate *date in self.dates) {
        FZDatepickerDateView *dateView = [[FZDatepickerDateView alloc] initWithFrame:CGRectMake(currentItemXPosition, 0, kFZDatepickerItemWidth, self.frame.size.height)];
        dateView.date = date;
        dateView.selected = [date isEqualToDate:self.selectedDate];
        [dateView setItemSelectionColor:self.selectedDateBottomLineColor];
        [dateView addTarget:self action:@selector(updateSelectedDate:) forControlEvents:UIControlEventValueChanged];

        [self.datesScrollView addSubview:dateView];

        currentItemXPosition += kFZDatepickerItemWidth + kFZDatepickerSpaceBetweenItems;
    }

    self.datesScrollView.contentSize = CGSizeMake(currentItemXPosition, self.frame.size.height);
}

- (void)updateSelectedDate:(FZDatepickerDateView *)dateView
{
    self.selectedDate = dateView.date;
}

- (void)updateSelectedDatePosition
{
    NSUInteger itemIndex = [self.dates indexOfObject:self.selectedDate];

    CGSize itemSize = CGSizeMake(kFZDatepickerItemWidth + kFZDatepickerSpaceBetweenItems, self.frame.size.height);
    CGFloat itemOffset = itemSize.width * itemIndex - (self.frame.size.width - (kFZDatepickerItemWidth + 2 * kFZDatepickerSpaceBetweenItems)) / 2;

    itemOffset = MAX(0, MIN(self.datesScrollView.contentSize.width - (self.frame.size.width ), itemOffset));

    [self.datesScrollView setContentOffset:CGPointMake(itemOffset, 0) animated:YES];
}

@end

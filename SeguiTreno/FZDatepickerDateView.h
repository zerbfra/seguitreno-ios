//
//  FZDatePickerDateView.h
//
//  Created by Francesco Zerbinati on 01/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//
//  Copyright (c) 2014 Dmitry Ivanenko. All rights reserved.
//

#import <UIKit/UIKit.h>


extern const CGFloat kFZDatepickerItemWidth;
extern const CGFloat kFZDatepickerSelectionLineWidth;


@interface FZDatepickerDateView : UIControl

// data
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) BOOL isSelected;

// ui
@property (strong, nonatomic) UILabel *dateLabel;
@property (nonatomic, strong) UIView *selectionView;

// methods
//- (void)setItemSelectionColor:(UIColor *)itemSelectionColor;

@end

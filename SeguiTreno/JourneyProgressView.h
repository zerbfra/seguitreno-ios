//
//  JourneyProgressView
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 14/11/14.
//  Copyright (c) 2014 Francesco. All rights reserved.
//  Inspired by Roma on 8/25/14.
//

#import <UIKit/UIKit.h>

@interface JourneyProgressView : UIView

- (id)initWithRow:(int)stop andMax:(int) max andCurrentStatus:(int) status andFrame:(CGRect)frame;

@end

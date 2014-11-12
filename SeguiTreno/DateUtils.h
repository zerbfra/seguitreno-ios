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

-(NSDate*) dateFrom:(NSTimeInterval) ts;
-(NSString*) showHHmm:(NSDate*) date;
-(NSString*) showDateAndHHmm:(NSDate*) date;

@end

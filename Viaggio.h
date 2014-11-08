//
//  Viaggio.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 07/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Viaggio : NSObject


@property (nonatomic,strong) Stazione  *origine;
@property (nonatomic,strong) Stazione *destinazione;

@property (nonatomic,strong) NSString *durata;

@property (nonatomic,strong) NSArray    *tragitto;


@end

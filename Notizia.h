//
//  Notizia.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notizia : NSObject

@property (strong,nonatomic) NSString *titolo;
@property (strong,nonatomic) NSString *data;
@property (strong,nonatomic) NSString *testo;

@property BOOL primopiano;

@end

//
//  Fermata.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 17/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Fermata : NSObject

@property (strong,nonatomic) NSString *binarioEffettivo;
@property (strong,nonatomic) NSString *binarioProgrammato;
@property  (strong,nonatomic) Stazione *stazione;

@property  NSTimeInterval orarioEffettivo;
@property  NSTimeInterval orarioProgrammato;

@property  BOOL raggiunta;

@property  int progressivo;
@property  NSInteger ritardo;




@end

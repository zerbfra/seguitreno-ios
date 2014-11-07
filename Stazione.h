//
//  Stazione.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stazione : NSObject

@property (strong,nonatomic) NSString *idStazione;
@property (strong,nonatomic) NSString *nome;
@property (strong,nonatomic) NSString *regione;

@property (nonatomic) float lat;
@property (nonatomic) float lon;

-(NSArray*) elencoStazioni;
-(void) formattaNome;

@end

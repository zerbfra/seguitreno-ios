//
//  Treno.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Treno : NSObject

@property (strong,nonatomic) NSString *numero;
@property (strong,nonatomic) Stazione *stazioneP;
@property (strong,nonatomic) Stazione *stazioneA;

@property (strong,nonatomic) NSString *categoria;

@property (strong,nonatomic) NSDate   *dataViaggio;

@property (nonatomic) NSInteger *ripetizione;  // Sun = 1, Sat = 7, 0 = unico
@property (nonatomic) NSDate *inizioRipetizione;
@property (nonatomic) NSDate *fineRipetizione;

@property  NSTimeInterval orarioPartenza;
@property  NSTimeInterval orarioArrivo;

@property (strong,nonatomic) NSString *stazioneUltimoRilevamento;
@property (strong,nonatomic) NSDate *oraUltimoRilevamento;

@property (strong,nonatomic) NSString *compDurata;
@property (strong,nonatomic) NSNumber *ritardo;

@property (nonatomic) BOOL soppresso;

@property (strong,nonatomic) NSArray *fermate;


@end

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

// tratta del treno da origine a destinazione
@property (strong,nonatomic) Stazione *origine;
@property (strong,nonatomic) Stazione *destinazione;

// percorso dell'utente da partenza ad arrivo
@property (strong,nonatomic) Stazione *partenza;
@property (strong,nonatomic) Stazione *arrivo;

// categoria treno (regionale, freccia...)
@property (strong,nonatomic) NSString *categoria;

// orario di arrivo nella stazione arrivo (nil se è origine)
@property  NSTimeInterval orarioArrivo;

// orario di partenza dalla stazione partenza (nil se è destinazione)
@property  NSTimeInterval orarioPartenza;

// dati di ultimo rilevamento del treno
@property (strong,nonatomic) NSString *stazioneUltimoRilevamento;
@property (strong,nonatomic) NSDate *oraUltimoRilevamento;

// durata treno da origine a destinazione
@property (strong,nonatomic) NSString *durata; 

// ritardo del treno
@property (strong,nonatomic) NSNumber *ritardo;

// indica se il treno è sopresso o meno
@property (nonatomic) BOOL soppresso;

// array delle fermate (che sono stazioni)
@property (strong,nonatomic) NSArray *fermate;


/*
// formatta una stringa con orario o data data la nsdate
-(NSString*) mostraOrario:(NSDate*) date;
-(NSString*) mostraData:(NSDate*) date;

// Ritorna l'NSDate da orarioPartenza di stazione partenza e orarioArrivo di stazione arrivo
-(NSDate*) dataPartenza;
-(NSDate*) dataArrivo;
*/

@end

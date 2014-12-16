//
//  Treno.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Treno : NSObject

@property (strong,nonatomic) NSString *idTreno;

@property (strong,nonatomic) NSString *numero;

// tratta del treno da origine a destinazione
@property (strong,nonatomic) Stazione *origine;
@property (strong,nonatomic) Stazione *destinazione;

// percorso dell'utente da partenza ad arrivo (ovviamente del treno)
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
@property  NSInteger ritardo;

// indica se il treno è sopresso o meno
@property (nonatomic) BOOL soppresso;

// dice se arrivato o meno
@property (nonatomic) BOOL arrivato;

// dice se il treno non è disponibile dalle API di trenitalia (di default obj-c istanzia a false, quindi corretto nel mio caso)
@property (nonatomic) BOOL nonDisponibile;

// array delle fermate (che sono stazioni)
@property (strong,nonatomic) NSArray *fermate;

-(NSString*) stringaStatoTemporale;
-(NSString*) stringaRitardo;

//ritorna categoria e numero treno
-(NSString*) stringaDescrizione;

// carica informazioni complete del treno
-(void) caricaInfoComplete:(void (^)(void))completionBlock;



@end

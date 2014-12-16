//
//  Stazione.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stazione : NSObject

// identificativo stazione, nome e regione
@property (strong,nonatomic) NSString *idStazione;
@property (strong,nonatomic) NSString *nome;
@property (strong,nonatomic) NSString *regione;

@property (strong,nonatomic) NSMutableArray* treniArrivo;
@property (strong,nonatomic) NSMutableArray* treniPartenza;

// coordinate della stazione
@property (nonatomic) float lat;
@property (nonatomic) float lon;

// usata per creare l'oggetto CLLocation date lat e lon
@property (nonatomic,strong) CLLocation *posizione;
// usato solo per sapere la distanza dalla posizione attuale
@property float distanza;

// ritorna l'elenco delle stazioni in un array
//-(NSArray*) elencoStazioni;
// formatta il nome (deprecata)
-(void) formattaNome;

// pulisce l'id della stazione (solitamente ha una lettera [A-Z] davanti al codice, utile in certe richieste a trenitalia, in altre no
-(NSString*) cleanId;

// carica treni in arrivo e partenza
-(void) caricaTreniStazione:(void (^)(void))completionBlock;

@end

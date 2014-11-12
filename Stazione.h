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



// coordinate della stazione
@property (nonatomic) float lat;
@property (nonatomic) float lon;

// ritorna l'elenco delle stazioni in un array
-(NSArray*) elencoStazioni;
// formatta il nome (deprecata)
-(void) formattaNome;
// pulisce l'id della stazione (solitamente ha una lettera [A-Z] davanti al codice, utile in certe richieste a trenitalia, in altre no
-(NSString*) cleanId;

@end

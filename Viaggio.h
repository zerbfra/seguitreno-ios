//
//  Viaggio.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 07/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Viaggio : NSObject

// id del viaggio
@property (nonatomic,strong) NSString *idViaggio;

// stazione di partenza ed arrivo dell'utente (solitamente diverse da origine e destinazione di un treno!)
@property (nonatomic,strong) Stazione  *partenza;
@property (nonatomic,strong) Stazione *arrivo;

// data del viaggio
@property (nonatomic,strong) NSDate     *data;

// durata dalla partenza alla destinazione
@property (nonatomic,strong) NSString *durata;

// array dei treni da prendere per arrivare da partenza ad arrivo
@property (nonatomic,strong) NSArray    *tragitto;

// se una ripetizione non è impostata è nil, altrimenti indica fino a quando ripetere la soluzione viaggio
@property (nonatomic,strong) NSDate     *fineRipetizione;

// calcola il numero di cambi
-(NSUInteger) numeroCambi;

// recuperano dai treni del tragitto l'orario di arrivo e quello di partenza
-(NSDate*) orarioArrivo;
-(NSDate*) orarioPartenza;

/*
-(NSString*) mostraOrario:(NSDate*) date;
-(NSString*) mostraData:(NSDate*) date;
 */

// formatta l'array tragitto considerando solo i numeri treno
-(NSArray*) jsonCompatibile;

@end

//
//  Stazione.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "Stazione.h"

@implementation Stazione

// formatta il nome della stazione
-(void) formattaNome {
    NSString *clean = self.nome.lowercaseString;
    
    // pulisco accenti trenitalia
    clean = [clean stringByReplacingOccurrencesOfString:@"`" withString:@"'"];
    
    // porto gli accenti sulle lettere
    clean = [clean stringByReplacingOccurrencesOfString:@"a'" withString:@"à"];
    clean = [clean stringByReplacingOccurrencesOfString:@"e'" withString:@"è"];
    clean = [clean stringByReplacingOccurrencesOfString:@"i'" withString:@"ì"];
    clean = [clean stringByReplacingOccurrencesOfString:@"o'" withString:@"ò"];
    clean = [clean stringByReplacingOccurrencesOfString:@"u'" withString:@"ù"];
    
    // maiuscolo inizio parole
    //CFStringCapitalize((CFMutableStringRef)clean, NULL);
    
    // sistemo gli apostrofi
    clean = [clean stringByReplacingOccurrencesOfString:@"'a" withString:@"'A"];
    clean = [clean stringByReplacingOccurrencesOfString:@"'e" withString:@"'E"];
    clean = [clean stringByReplacingOccurrencesOfString:@"'i" withString:@"'I"];
    clean = [clean stringByReplacingOccurrencesOfString:@"'o" withString:@"'O"];
    clean = [clean stringByReplacingOccurrencesOfString:@"'u" withString:@"'U"];
    
    // punto
    clean = [clean stringByReplacingOccurrencesOfString:@"." withString:@". "];
    // trattino
    clean = [clean stringByReplacingOccurrencesOfString:@" - " withString:@"-"];
    clean = [clean stringByReplacingOccurrencesOfString:@"- " withString:@"-"];
    clean = [clean stringByReplacingOccurrencesOfString:@" -" withString:@"-"];
    clean = [clean stringByReplacingOccurrencesOfString:@"-" withString:@" - "];
    
    //clean = [clean capitalizedStringWithLocale:[NSLocale currentLocale]];
    
    // maiuscolo inizio parole
    clean = [clean capitalizedString];
    
    
    self.nome = clean;
    
}
// pulisce ID della stazione, a volte trenitalia ritorna l'ID con una "S" davanti
-(NSString*) cleanId {
    return [self.idStazione substringFromIndex:1];
}

// carico i treni in arrivo  e in partenza dell'oggetto stazione
-(void) caricaTreniStazione:(void (^)(void))completionBlock {
    
    self.treniArrivo = [NSMutableArray array];
    self.treniPartenza = [NSMutableArray array];
    
    // creo un gruppo di dispatch
    dispatch_group_t group = dispatch_group_create();
    
    
    dispatch_group_enter(group);
    
    [[APIClient sharedClient] requestWithPath:@"treniArrivo" andParams:@{@"stazione":self.idStazione} completion:^(NSDictionary *response) {
        
        for(NSDictionary *trenoDict in response) {
            // controllo che non sia stato restituito un null (può succedere in casi eccezzionali)
            Treno *treno = [[Treno alloc] init];
            treno.categoria = [trenoDict objectForKey:@"categoria"];
            treno.numero = [trenoDict objectForKey:@"numero"];
            Stazione *origine = [[Stazione alloc] init];
            origine.idStazione = [trenoDict objectForKey:@"idOrigine"];
            origine.nome = [trenoDict objectForKey:@"origine"];
            
            [origine formattaNome];
            
            treno.origine = origine;
            treno.orarioArrivo = [[trenoDict objectForKey:@"orarioArrivo"] intValue];
            treno.ritardo = [[trenoDict objectForKey:@"ritardo"] intValue];
            [self.treniArrivo addObject:treno];
            
        }
        
        
        
        dispatch_group_leave(group);
        
    }];
    
    dispatch_group_enter(group);
    
    [[APIClient sharedClient] requestWithPath:@"treniPartenza" andParams:@{@"stazione":self.idStazione} completion:^(NSDictionary *response) {
        
        for(NSDictionary *trenoDict in response) {
            // controllo che non sia stato restituito un null (può succedere in casi eccezzionali)
            Treno *treno = [[Treno alloc] init];
            treno.categoria = [trenoDict objectForKey:@"categoria"];
            treno.numero = [trenoDict objectForKey:@"numero"];
            Stazione *destinazione = [[Stazione alloc] init];
            destinazione.nome = [trenoDict objectForKey:@"destinazione"];
            
            Stazione *origine = [[Stazione alloc] init];
            origine.idStazione = [trenoDict objectForKey:@"idOrigine"];
            
            [destinazione formattaNome];
            
            treno.origine = origine;
            treno.destinazione = destinazione;
            
            treno.ritardo = [[trenoDict objectForKey:@"ritardo"] intValue];
            treno.orarioPartenza = [[trenoDict objectForKey:@"orarioPartenza"] intValue];
            [self.treniPartenza addObject:treno];
            
        }
        
        dispatch_group_leave(group);
        
    }];
    

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // tutte le richieste completate
        NSLog(@"Finito le richieste al server");
        completionBlock();
        
    });
    
}



@end

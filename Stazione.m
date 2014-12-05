//
//  Stazione.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "Stazione.h"

@implementation Stazione

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
    CFStringCapitalize((CFMutableStringRef)clean, NULL);
    
    // sistemo gli apostrofi
    clean = [clean stringByReplacingOccurrencesOfString:@"'a" withString:@"'A"];
    clean = [clean stringByReplacingOccurrencesOfString:@"'e" withString:@"'E"];
    clean = [clean stringByReplacingOccurrencesOfString:@"'i" withString:@"'I"];
    clean = [clean stringByReplacingOccurrencesOfString:@"'o" withString:@"'O"];
    clean = [clean stringByReplacingOccurrencesOfString:@"'u" withString:@"'U"];
    
    self.nome = clean;
    
}

-(NSString*) cleanId {
    return [self.idStazione substringFromIndex:1];
}



@end

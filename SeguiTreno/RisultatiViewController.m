//
//  RisultatiViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 01/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "RisultatiViewController.h"

@interface RisultatiViewController ()

@end

@implementation RisultatiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.soluzioniPossibili = [[NSMutableArray alloc] init];
    
    // ovvero è stato inserito il numero del treno anzichè i dati delle stazioni
    if([self.numeroTreno length] > 0) {
        [self trovaTrenoDaNumero];
        
    }else [self trovaTrenoDaStazioni];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (self.fascia) {
        case 0:
            return [self numerosoluzioniTraOra:0 e:12];
            break;
        case 1:
            return [self numerosoluzioniTraOra:12 e:18];
            break;
        case 2:
            return [self numerosoluzioniTraOra:18 e:24];
            break;
        default:
            return 0;
            break;
    }
}

-(void) trovaTrenoDaStazioni {
    
    NSNumber *ts = [NSNumber numberWithDouble:[self.query.data timeIntervalSince1970]];
    
    [[APIClient sharedClient] requestWithPath:@"ricerca" andParams:@{@"partenza":[self.query.partenza cleanId],@"arrivo":[self.query.arrivo cleanId],@"data":ts} completion:^(NSArray *response) {
        //NSLog(@"Response: %@", response);
        
        
        for (NSDictionary *trenoDict in response) {
            
            Treno *treno = [[Treno alloc] init];
            
            Stazione *partenza = [[Stazione alloc] init];
            Stazione *arrivo = [[Stazione alloc] init];
            
   
            
            partenza.nome = self.query.partenza.nome;
            arrivo.nome = self.query.arrivo.nome;
            partenza.idStazione = [self.query.partenza cleanId];
            arrivo.idStazione   = [self.query.arrivo cleanId];

            
            treno.numero = [trenoDict objectForKey:@"numero"];
            treno.orarioArrivo = [[trenoDict objectForKey:@"orarioArrivo"] doubleValue];
            treno.orarioPartenza = [[trenoDict objectForKey:@"orarioPartenza"] doubleValue];
            treno.categoria = [trenoDict objectForKey:@"categoria"];

            treno.origine = partenza;
            treno.destinazione = arrivo;
            
            
            
            [self.soluzioniPossibili addObject:treno];
            
        }
        
        [self.tableView reloadData];
        
        
        
    }];
    
    
}

-(void) trovaTrenoDaNumero {
    
    [[APIClient sharedClient] requestWithPath:@"ricerca" andParams:@{@"numero":self.numeroTreno} completion:^(NSArray *response) {
        //NSLog(@"Response: %@", response);
        
        
        for (NSDictionary *trenoDict in response) {
            
            
            Stazione *partenza = [[Stazione alloc] init];
            Stazione *arrivo = [[Stazione alloc] init];
            
            partenza.nome = [trenoDict objectForKey:@"origine"];
            arrivo.nome = [trenoDict objectForKey:@"destinazione"];
            partenza.idStazione = [trenoDict objectForKey:@"idOrigine"];
            arrivo.idStazione = [trenoDict objectForKey:@"idDestinazione"];
            [partenza formattaNome];
            [arrivo formattaNome];
            [partenza cleanId];
            [arrivo cleanId];
            
            
            
            Treno *treno = [[Treno alloc] init];
            treno.numero = [trenoDict objectForKey:@"numero"];
            treno.orarioArrivo = [[trenoDict objectForKey:@"orarioArrivo"] doubleValue];
            treno.orarioPartenza = [[trenoDict objectForKey:@"orarioPartenza"] doubleValue];
            treno.categoria = [trenoDict objectForKey:@"categoria"];
            treno.origine = partenza;
            treno.destinazione = arrivo;
            
            
            
            [self.soluzioniPossibili addObject:treno];
            
        }
        
        [self.tableView reloadData];
        
        
        
    }];
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RisultatoRicercaTableViewCell  *cell = (RisultatoRicercaTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"risultatoRicerca" forIndexPath:indexPath];
    
    // treno da numero
    if([self.numeroTreno length] > 0) {
        cell.treno = self.soluzioniPossibili[indexPath.row];
    } else {
        
        NSArray *treniSezione;
        
        switch (self.fascia) {
            case 0:
                treniSezione = [self treniTraOra:0 e:12];
                break;
            case 1:
                treniSezione = [self treniTraOra:12 e:18];
                break;
            case 2:
                treniSezione = [self treniTraOra:18 e:24];
                break;
            default:
                treniSezione = nil;
                break;
        }
        cell.treno = [treniSezione objectAtIndex:indexPath.row];
        
    }
    
    [cell disegna];
    
    
    return cell;
}


#pragma mark - Funzioni ausiliari per le date e soluzioni viaggio


-(NSArray*)treniTraOra:(NSInteger) inizio e:(NSInteger) fine {
    
    NSDate *dataInizio = [[DateUtils shared] date:self.query.data At:inizio]; //[self todayAt:inizio];
    NSDate *dataFine = [[DateUtils shared] date:self.query.data At:fine];
    
    NSMutableArray *treniCompresi = [[NSMutableArray alloc] init];
    
    for(Treno* treno in self.soluzioniPossibili) {
        NSDate *partenza = [[DateUtils shared] dateFrom:treno.orarioPartenza];
        
        if([[DateUtils shared] date:partenza isBetweenDate:dataInizio andDate:dataFine]) [treniCompresi addObject:treno];
    }
    return treniCompresi;
}

-(NSInteger)numerosoluzioniTraOra:(NSInteger) inizio e:(NSInteger) fine {
    
    if([self.numeroTreno length] > 0) {
        return [self.soluzioniPossibili count];
    } else  return [[self treniTraOra:inizio e:fine] count];
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"dettaglioTreno" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"dettaglioTreno"]) {
        
        RisultatoRicercaTableViewCell *trenocell = (RisultatoRicercaTableViewCell*) sender;
        
        DettaglioTrenoViewController *destination = (DettaglioTrenoViewController*) [segue destinationViewController];
        
        NSLog(@"%@",trenocell.treno.origine.idStazione);
        destination.treno = trenocell.treno;
        
        // dico al dettaglio se è il treno della giornata attuale o meno
        destination.attuale = YES;
        destination.dataTreno = [NSDate date];
        
        
    }
}


@end

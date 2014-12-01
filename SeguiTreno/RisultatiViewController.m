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
    [self trovaSoluzioniTreno];
    
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

-(void) trovaSoluzioniTreno {
    
    NSNumber *ts = [NSNumber numberWithDouble:[self.query.data timeIntervalSince1970]];
    
    [[APIClient sharedClient] requestWithPath:@"soluzioniViaggio" andParams:@{@"partenza":[self.query.partenza cleanId],@"arrivo":[self.query.arrivo cleanId],@"data":ts} completion:^(NSArray *response) {
        //NSLog(@"Response: %@", response);
        
        
        for (NSDictionary *solDict in response) {
            
            Viaggio  *soluzione = [[Viaggio alloc] init];
            
            Stazione *partenza = [[Stazione alloc] init];
            Stazione *arrivo = [[Stazione alloc] init];
            
            
            partenza.nome = self.query.partenza.nome;
            
            arrivo.nome = self.query.arrivo.nome;
            
            partenza.idStazione            = [self.query.partenza cleanId];
            arrivo.idStazione       = [self.query.arrivo cleanId];
            
            soluzione.partenza = partenza;
            soluzione.arrivo = arrivo;
            

            
            NSMutableArray *tmpTragitto = [[NSMutableArray alloc] init];
            
            for(NSDictionary *trenoDict in [solDict objectForKey:@"tragitto"]) {
                
                Treno *treno = [[Treno alloc] init];
                treno.numero = [trenoDict objectForKey:@"numero"];
                treno.orarioArrivo = [[trenoDict objectForKey:@"orarioArrivo"] doubleValue];
                treno.orarioPartenza = [[trenoDict objectForKey:@"orarioPartenza"] doubleValue];
                treno.categoria = [trenoDict objectForKey:@"categoria"];
                treno.origine = partenza;
                treno.destinazione = arrivo;

                
                [tmpTragitto addObject:treno];
            }
            
            soluzione.tragitto = [tmpTragitto copy];
            
            
            // aggiungo solo treni diretti, no cambi!
            if([soluzione.tragitto count] == 1) {
                [self.soluzioniPossibili addObject:soluzione];
            }
            
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
    
    NSArray *soluzioniSezione;
    
    switch (self.fascia) {
        case 0:
            soluzioniSezione = [self soluzioniTraOra:0 e:12];
            break;
        case 1:
            soluzioniSezione = [self soluzioniTraOra:12 e:18];
            break;
        case 2:
            soluzioniSezione = [self soluzioniTraOra:18 e:24];
            break;
        default:
            soluzioniSezione = nil;
            break;
    }
    
    
    cell.soluzione = [soluzioniSezione objectAtIndex:indexPath.row];
    
    [cell disegna];
    
    
    return cell;
}


#pragma mark - Funzioni ausiliari per le date e soluzioni viaggio


-(NSArray*)soluzioniTraOra:(NSInteger) inizio e:(NSInteger) fine {
    
    NSDate *dataInizio = [[DateUtils shared] date:self.query.data At:inizio]; //[self todayAt:inizio];
    NSDate *dataFine = [[DateUtils shared] date:self.query.data At:fine];
    
    NSMutableArray *viaggiCompresi = [[NSMutableArray alloc] init];
    
    for(Viaggio* soluzione in self.soluzioniPossibili) {
        NSDate *partenza = [soluzione orarioPartenza];
        
        if([[DateUtils shared] date:partenza isBetweenDate:dataInizio andDate:dataFine]) [viaggiCompresi addObject:soluzione];
    }
    return viaggiCompresi;
}

-(NSInteger)numerosoluzioniTraOra:(NSInteger) inizio e:(NSInteger) fine {
    
    return [[self soluzioniTraOra:inizio e:fine] count];
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
        Treno *primo = trenocell.soluzione.tragitto[0];
        NSLog(@"%@",primo.origine.idStazione);
        destination.treno = primo;
        
        // dico al dettaglio se è il treno della giornata attuale o meno
        destination.attuale = YES;
        destination.dataTreno = [NSDate date];
        
        
    }
}


@end

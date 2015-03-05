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
    

    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator startAnimating];
    
    // ovvero è stato inserito il numero del treno anzichè i dati delle stazioni
    if([self.numeroTreno length] > 0) {
        NSLog(@"da numero");
        [self trovaTrenoDaNumero:^{
            [self disegnaRisultati];
            [activityIndicator stopAnimating];
        }];
    }
    else {
        NSLog(@"da stazioni");
        [self trovaTrenoDaStazioni:^{
            [self disegnaRisultati];
            [activityIndicator stopAnimating];
        }];
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void) disegnaRisultati {
    
    NSLog(@"%@",self.soluzioniPossibili);
    
    if([self.soluzioniPossibili count] > 0) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        // soluzioni non trovate
        NSLog(@"non trovo niente");
        
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Non trovo nessuna soluzione viaggio" message:@"Probabilmente il tragitto che cerchi non è ancora supportato dall'app.\n\nProva a contattare lo sviluppatore dalle impostazioni dell'app specificando che tragitto stai cercando e che società gestisce il trasporto." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

// mi torna indietro se compare alert e clicco su ok
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
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

// metodo che recupera i treni dati la stazione e la data
-(void) trovaTrenoDaStazioni:(void (^)(void))completionBlock {
    
    NSNumber *ts = [NSNumber numberWithDouble:[self.query.data timeIntervalSince1970]];
    
    [[APIClient sharedClient] requestWithPath:@"ricerca" andParams:@{@"partenza":[self.query.partenza cleanId],@"arrivo":[self.query.arrivo cleanId],@"data":ts} completion:^(NSDictionary *response) {
        
        NSLog(@"%@",response);
        for (NSDictionary *trenoDict in response) {

            Treno *treno = [[Treno alloc] init];
            
            Stazione *partenza = [[Stazione alloc] init];
            Stazione *arrivo = [[Stazione alloc] init];
            
   
            
            partenza.nome = self.query.partenza.nome;
            arrivo.nome = self.query.arrivo.nome;
            partenza.idStazione = self.query.partenza.idStazione;
            arrivo.idStazione   = self.query.arrivo.idStazione;

            
            treno.numero = [trenoDict objectForKey:@"numero"];
            treno.orarioArrivo = [[trenoDict objectForKey:@"orarioArrivo"] doubleValue];
            treno.orarioPartenza = [[trenoDict objectForKey:@"orarioPartenza"] doubleValue];
            treno.categoria = [trenoDict objectForKey:@"categoria"];

            
            treno.partenza = partenza;
            treno.arrivo = arrivo;
            
            [self.soluzioniPossibili addObject:treno];
            
        }
        
        completionBlock();
        
        
    }];
    
    
}

// trova un treno dato il suo numero (possono esserci più treni con lo stesso numero
-(void) trovaTrenoDaNumero:(void (^)(void))completionBlock {
    
    [[APIClient sharedClient] requestWithPath:@"ricerca" andParams:@{@"numero":self.numeroTreno} completion:^(NSDictionary *response) {
        NSLog(@"Response: %@", response);
        
        
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
            treno.soppresso = [[trenoDict objectForKey:@"sopresso"] boolValue];
            
            // origine e destinazione concidenti con partenza e arrivo in quanto ricerca per numero
            treno.origine = partenza;
            treno.destinazione = arrivo;
            treno.partenza = partenza;
            treno.arrivo = arrivo;
            
            
            [self.soluzioniPossibili addObject:treno];
            
        }
        
        completionBlock();
    
        
    }];
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

// mostra i treni della fascia oraria selezionata in precedenza
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
    
    NSDate *dataInizio = [[DateUtils shared] date:self.query.data At:inizio];
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
    
    RisultatoRicercaTableViewCell *cell  = (RisultatoRicercaTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator startAnimating];
    [cell setUserInteractionEnabled:NO];

    
    [cell.treno caricaInfoComplete:^{
        [self performSegueWithIdentifier:@"dettaglioTreno" sender:cell];
        [activityIndicator stopAnimating];
        [cell setUserInteractionEnabled:YES];

    }];
    

    
}


#pragma mark - Navigation

// manda al dettaglio del treno
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

//
//  SoluzioneViaggioViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 07/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "SoluzioneViaggioViewController.h"
#import "SoluzioneTableViewCell.h"
#import "DettaglioSoluzioneViewController.h"
#import "TFHpple.h"

@interface SoluzioneViaggioViewController ()

@end

@implementation SoluzioneViaggioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    
    self.soluzioniPossibili = [[NSMutableArray alloc] init];
    
    // attivo indicatore loading
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator startAnimating];
    
    // chiamo per trovare soluzioni viaggio e al completamento aggiorno la vista
    [self trovaSoluzioniTreno:^{
        if([self.soluzioniPossibili count] > 0) {
            [self.tableView reloadData];
        } else {
            // soluzioni non trovate
            NSLog(@"non trovo niente, cerco con orario trenitalia...");
            
            /*
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Non trovo nessuna soluzione viaggio" message:@"Probabilmente il tragitto che cerchi non è ancora supportato dall'app.\n\nProva a contattare lo sviluppatore dalle impostazioni dell'app specificando che tragitto stai cercando e che società gestisce il trasporto." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            */
             
            [self soluzioniOrarioTrenitalia:^{
                    NSLog(@"Aggiorno tabella");
                    [self.tableView reloadData];
            }];

        }
        [activityIndicator stopAnimating];
    }];
    
}

// mi torna indietro se compare alert e clicco su ok
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}

// metodo che ricerca le soluzioni su orario.trenitalia.com (per i treni trenord/lenord e compagnia)
-(void) soluzioniOrarioTrenitalia:(void (^)(void))completionBlock {

    NSString *day = [[DateUtils shared] getDayNumber:self.query.data];
    NSString *month = [[DateUtils shared] getMonthNumber:self.query.data];
    NSString *year = [[DateUtils shared] getYearNumber:self.query.data];
    
    NSString *stringaOrario = [NSString stringWithFormat:@"http://orario.trenitalia.com/b2c/nppPriceTravelSolutions.do?lang=it&stazin=%@&stazout=%@&datag=%@&datam=%@&dataa=%@&timsh=1&timsm=0&nreq=25&npag=1&sort=0&economy=1&det=&solotreno=0&noreservation=0&traintype=&car=0",self.query.partenza.nome,self.query.arrivo.nome,day,month,year];
    
    stringaOrario = [stringaOrario stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"URL orario trenitalia: %@",stringaOrario);
    
    [[APIClient sharedClient] getPageWithURL:stringaOrario completion:^(NSData *data) {
        // parso il contenuto della pagina
        [self parseTrenitalia:data];
        completionBlock();
        
    }];
    
}

-(void) parseTrenitalia:(NSData*) data {
    
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:data];
    
    // path di ricerca
    NSString *XpathQueryString = @"//tbody/tr[@class='odd' or @class='even']//td";
    NSArray *nodes = [tutorialsParser searchWithXPathQuery:XpathQueryString];
    
    if([nodes count] <= 0) {
        NSLog(@"Errore su ricerca orario trenitalia");
#warning comunicare un messaggio all'utente (segnalazione malpelo, qua faceva crashare)
        return;
    }
    
    NSMutableArray *treniValidi = [NSMutableArray array];
    
    for (TFHppleElement *element in nodes) {
        //NSLog(@"Elemento: %@",[[element firstChild] content]);
        
        NSString *content =[[element firstChild] content];
        // rimuovo schifezze
        if(![content containsString:@"ND"] && ![content containsString:@"\n"] && [content length]>0) {
            [treniValidi addObject:[[element firstChild] content]];
        }
    }
    
    /* QUI RIMUOVO QUELLI COL CAMBIO, esempio da asso a bovisa:
     "04:45",
     "06:13",
     "01:28",
     "2610A ",
     "05:37", => cambio
     "12610 ",
     "06:05",
     "07:13",
     */
    
    NSMutableArray *discardedItems = [NSMutableArray array];
    for(int i=4;i<[treniValidi count]-1; i++) {
        if ([treniValidi[i] containsString:@":"] && ![treniValidi[i-1] containsString:@":"] && ![treniValidi[i+1] containsString:@":"]) {
            
            [discardedItems addObject:treniValidi[i-4]];
            [discardedItems addObject:treniValidi[i-3]];
            [discardedItems addObject:treniValidi[i-2]];
            [discardedItems addObject:treniValidi[i-1]];
            [discardedItems addObject:treniValidi[i-0]];
            [discardedItems addObject:treniValidi[i+1]];
            
        }
    }
    
    [treniValidi removeObjectsInArray:discardedItems];
    
    // a questo punto ho l'array dei treni validi, lo sistemo
    for(int i=0; i <[treniValidi count]; i+=4) {
        
        Viaggio  *soluzione = [[Viaggio alloc] init];
        Treno *treno = [[Treno alloc] init];
        
        // viene da orario trenitalia, setto il flag!
        treno.daOrarioTrenitalia = true;
        
        NSMutableArray *tmpTragitto = [[NSMutableArray alloc] init];
        
        Stazione *partenza = [[Stazione alloc] init];
        Stazione *arrivo = [[Stazione alloc] init];
        
        partenza.nome = self.query.partenza.nome;
        
        arrivo.nome = self.query.arrivo.nome;
        
        soluzione.partenza = partenza;
        soluzione.arrivo  = arrivo;
        
        soluzione.durata = [treniValidi objectAtIndex:i+2];
        
        treno.numero = [treniValidi objectAtIndex:i+3];
        
        // a 0 HH e a 1 mm
        NSArray *orarioArrivo = [[treniValidi objectAtIndex:i+1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
        NSArray *orarioPartenza = [[treniValidi objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
        NSDate *orarioADate = [[DateUtils shared] date:self.query.data At:[orarioArrivo[0] doubleValue] min:[orarioArrivo[1] doubleValue]];
        NSDate *orarioPDate = [[DateUtils shared] date:self.query.data At:[orarioPartenza[0] doubleValue] min:[orarioPartenza[1] doubleValue]];
        
        treno.orarioArrivo = [[DateUtils shared] timestampFrom:orarioADate];
        treno.orarioPartenza = [[DateUtils shared] timestampFrom:orarioPDate];
        
        treno.partenza = partenza;
        treno.arrivo = arrivo;
        
        treno.categoria = @"";
        
        [tmpTragitto addObject:treno];
        soluzione.tragitto = [tmpTragitto copy];
        [self.soluzioniPossibili addObject:soluzione];
        
    }
}

// richiede le soluzioni viaggio recuperate dal server
-(void) trovaSoluzioniTreno:(void (^)(void))completionBlock {

    NSNumber *ts = [NSNumber numberWithDouble:[self.query.data timeIntervalSince1970]];

    // richiedo soluzioni al server
    [[APIClient sharedClient] requestWithPath:@"soluzioniViaggio" andParams:@{@"partenza":[self.query.partenza cleanId],@"arrivo":[self.query.arrivo cleanId],@"data":ts} completion:^(NSDictionary *response) {
        NSLog(@"%@",ts);
        NSLog(@"%@",response);
        for (NSDictionary *solDict in response) {
            
            Viaggio  *soluzione = [[Viaggio alloc] init];
            
            Stazione *partenza = [[Stazione alloc] init];
            Stazione *arrivo = [[Stazione alloc] init];
            
            partenza.nome = self.query.partenza.nome;
            
            arrivo.nome = self.query.arrivo.nome;
             
            partenza.idStazione            = self.query.partenza.idStazione;
            arrivo.idStazione       = self.query.arrivo.idStazione;
            
            soluzione.partenza = partenza;
            soluzione.arrivo = arrivo;
            
            NSMutableArray *tmpTragitto = [[NSMutableArray alloc] init];
            
            for(NSDictionary *trenoDict in [solDict objectForKey:@"tragitto"]) {
                
                Treno *treno = [[Treno alloc] init];
                treno.numero = [trenoDict objectForKey:@"numero"];
                treno.orarioArrivo = [[trenoDict objectForKey:@"orarioArrivo"] doubleValue];
                treno.orarioPartenza = [[trenoDict objectForKey:@"orarioPartenza"] doubleValue];
                treno.categoria = [trenoDict objectForKey:@"categoria"];
                
                Stazione *stazioneP = [[Stazione alloc] init];
                stazioneP.nome = [trenoDict objectForKey:@"origine"];
                
                Stazione *stazioneA = [[Stazione alloc] init];
                stazioneA.nome = [trenoDict objectForKey:@"destinazione"];
                
                
                treno.partenza = stazioneP;
                treno.arrivo = stazioneA;

                [tmpTragitto addObject:treno];
            }
            
            soluzione.tragitto = [tmpTragitto copy];
            
            soluzione.durata            = [solDict objectForKey:@"durata"];
            
            // aggiungo l'oggetto agli oggetti remoti, solo con meno di 5 treni/4cambi (in teoria trenitalia non fornisce soluzioni più ampie)
            if([soluzione.tragitto count] < 5)
            [self.soluzioniPossibili addObject:soluzione];
            
        }
        
        completionBlock();

    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    
    // prima delle 6
    // tra le 6 e le 9
    // tra le 9 e le 12
    // tra le 12 e le 15
    // tra le 15 e le 18
    // tra le 18 e le 00
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    NSInteger numero;
    
    switch (section) {
        case 0:
            numero = [self numerosoluzioniTraOra:0 e:6];
            break;
        case 1:
            numero = [self numerosoluzioniTraOra:6 e:9];
            break;
        case 2:
            numero = [self numerosoluzioniTraOra:9 e:12];
            break;
        case 3:
            numero = [self numerosoluzioniTraOra:12 e:15];
            break;
        case 4:
            numero = [self numerosoluzioniTraOra:15 e:18];
            break;
        case 5:
            numero = [self numerosoluzioniTraOra:18 e:24];
            break;
        
        default:
            break;
    }
    
    return numero;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SoluzioneTableViewCell *cell = (SoluzioneTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"soluzioneViaggio" forIndexPath:indexPath];
    
    // Configure the cell...
    NSArray *soluzioniSezione;
    
    switch (indexPath.section) {
        case 0:
            soluzioniSezione = [self soluzioniTraOra:0 e:6];
            break;
        case 1:
            soluzioniSezione =[self soluzioniTraOra:6 e:9];
            break;
        case 2:
            soluzioniSezione =[self soluzioniTraOra:9 e:12];
            break;
        case 3:
            soluzioniSezione =[self soluzioniTraOra:12 e:15];
            break;
        case 4:
            soluzioniSezione =[self soluzioniTraOra:15 e:18];
            break;
        case 5:
            soluzioniSezione =[self soluzioniTraOra:18 e:24];
            break;
            
        default:
            break;
    }
    
    cell.soluzione = [soluzioniSezione objectAtIndex:indexPath.row];
    
    [cell disegna];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sezione;
    
    // prima delle 6
    // tra le 6 e le 9
    // tra le 9 e le 12
    // tra le 12 e le 15
    // tra le 15 e le 18
    // tra le 18 e le 00
    
    switch (section) {
        case 0:
            sezione = @"Prima delle 6";
            break;
        case 1:
            sezione = @"Tra le 6 e le 9";
            break;
        case 2:
            sezione = @"Tra le 9 e le 12";
            break;
        case 3:
            sezione = @"Tra le 12 e le 15";
            break;
        case 4:
            sezione = @"Tra le 15 e le 18";
            break;
        case 5:
            sezione = @"Dopo le 18";
            break;
            
        default:
            break;
    }
    if([self.soluzioniPossibili count] > 0 )return sezione;
    else return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"dettaglioSoluzione" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    
}

#pragma mark - Funzioni ausiliari per le date e soluzioni viaggio

// restituisce le sole soluzioni comprese tra due orari
-(NSArray*)soluzioniTraOra:(NSInteger) inizio e:(NSInteger) fine {
    
    NSDate *dataInizio = [[DateUtils shared] date:self.query.data At:inizio];
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




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    SoluzioneTableViewCell *senderCell = (SoluzioneTableViewCell*)sender;
    
    // chiama il dettaglio
    if([segue.identifier  isEqual: @"dettaglioSoluzione"]) {
        
        DettaglioSoluzioneViewController *destination = (DettaglioSoluzioneViewController*)[segue destinationViewController];
        NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;

        destination.delegate = [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
        destination.soluzione = senderCell.soluzione;
        
    }
    
    
}

@end

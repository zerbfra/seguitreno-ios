//
//  MainView.m
//  TrenoSmart
//
//  Created by Francesco Zerbinati on 04/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "MainViewController.h"
#import "DettaglioTrenoViewController.h"

@implementation MainViewController


-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    // status bar bianca
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    [self.datepicker fillDatesFromCurrentDate:15];
    
    [self.datepicker selectDateAtIndex:0];
    
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTrain:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.treniTable.delegate = self;
    self.treniTable.dataSource = self;
    self.treniTable.backgroundColor = BACKGROUND_COLOR;
    self.treniTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.datepicker addTarget:self action:@selector(updateSelectedDate) forControlEvents:UIControlEventValueChanged];
    
    self.viaggi = [NSMutableArray array];
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.treniTable deselectRowAtIndexPath:[self.treniTable indexPathForSelectedRow] animated:YES];
    [self caricaViaggi];
}

-(void) caricaViaggi {
    
    NSInteger start,end;
    
    [self.viaggi removeAllObjects];
    
    if(self.datepicker.selectedDate == nil) {
        start = [[DateUtils shared] timestampFrom:[[DateUtils shared] date:[NSDate date] At:0]];
        end = [[DateUtils shared] timestampFrom:[[DateUtils shared] date:[NSDate date] At:24]];
    }
    else {
        start = [[DateUtils shared] timestampFrom:[[DateUtils shared] date:self.datepicker.selectedDate At:0]];
        end = [[DateUtils shared] timestampFrom:[[DateUtils shared] date:self.datepicker.selectedDate At:24]];
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM viaggi WHERE orarioPartenza BETWEEN '%tu' AND '%tu' ORDER BY orarioPartenza",start,end];
    
    NSArray *dbViaggi = [[DBHelper sharedInstance] executeSQLStatement:query];
    
    
    for (NSDictionary* viaggoSet in dbViaggi) {
        Viaggio *viaggio = [[Viaggio alloc] init];
        viaggio.idViaggio = [viaggoSet objectForKey:@"id"];
        viaggio.durata = [viaggoSet objectForKey:@"durata"];
        
        
        NSString*stmt = [NSString stringWithFormat:@"SELECT * FROM treni WHERE id IN (SELECT idTreno FROM 'treni-viaggi' WHERE idViaggio = '%@') ORDER BY orarioPartenza",viaggio.idViaggio];
        NSArray *treni = [[DBHelper sharedInstance] executeSQLStatement:stmt];
        if([treni count] > 0) {
            
            
            NSMutableArray *tragitto = [NSMutableArray array];
            
            for (NSDictionary* trenoSet in treni) {
                
                //viaggio.idViaggio = [trenoSet objectForKey:@"idSoluzione"];
                
                Treno *trovato = [[Treno alloc] init];
                trovato.numero = [trenoSet objectForKey:@"numero"];
                
                trovato.idTreno = [trenoSet objectForKey:@"id"];
                
                //NSLog(@"Treno: %@",trovato.numero);
                
                Stazione *origine = [[Stazione alloc] init];
                origine.idStazione = [trenoSet objectForKey:@"idOrigine"];
                //Stazione *destinazione = [[Stazione alloc] init];
                //destinazione.idStazione = [trenoSet objectForKey:@"idDestinazione"];
                
                trovato.origine = origine;
                
                Stazione *partenza = [[Stazione alloc] init];
                partenza.nome = [trenoSet objectForKey:@"nomePartenza"];
                
                
                
                Stazione *arrivo = [[Stazione alloc] init];
                arrivo.nome = [trenoSet objectForKey:@"nomeArrivo"];
                
                trovato.partenza = partenza;
                trovato.arrivo = arrivo;
                
                trovato.orarioPartenza = [[trenoSet objectForKey:@"orarioPartenza"] intValue];
                trovato.orarioArrivo = [[trenoSet objectForKey:@"orarioArrivo"] intValue];
                
                trovato.categoria =  [trenoSet objectForKey:@"categoria"];
                
                
                
                [tragitto addObject:trovato];
                
            }
            
            viaggio.tragitto = tragitto;
            [self.viaggi addObject:viaggio];
            
            
        }
    }
    
    // Aggiorno tabella con un'animazione (con i dati locali)
    [UIView transitionWithView:self.treniTable
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^(void) {
                        
                    } completion:NULL];
    
    
    // richiedo informazioni aggiuntive sui treni se sono quelli della giornata (quindi index = 0)
    
    if([self.datepicker selectedIndex] == 0) {
        NSLog(@"Recupero informazioni live...");
        [self requestGroupTrain:[self elencoTreni]  completion:^(NSArray *response) {
            // aggiorno per le informazioni recuperate dal server
            [self.treniTable reloadData];
        }];
    } else {
        NSLog(@"Stampo treni senza live...");
        [self.treniTable reloadData];
    }
    
    
}

-(NSMutableArray*) elencoTreni {
    
    NSMutableArray* treni = [NSMutableArray array];
    
    for(Viaggio* viaggio in self.viaggi) {
        for(Treno* treno in viaggio.tragitto) {
            [treni addObject:treno];
        }
    }
    
    return treni;
}


-(void) requestGroupTrain:(NSMutableArray*) batch completion:(void (^)(NSArray *))completion {
    
    // creo un gruppo di dispatch
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableArray *final = [NSMutableArray array];
    
    for(Treno *treno in batch)
    {
        
        dispatch_group_enter(group);
        
        [[APIClient sharedClient] requestWithPath:@"trovaTreno" andParams:@{@"numero":treno.numero,@"origine":treno.origine.idStazione,@"includiFermate":[NSNumber numberWithBool:false]} completion:^(NSArray *response) {
            
            for(NSDictionary *trenoDict in response) {
                treno.ritardo = [[trenoDict objectForKey:@"ritardo"] intValue];
                treno.soppresso = [[trenoDict objectForKey:@"soppresso"] boolValue];
                treno.arrivato = [[trenoDict objectForKey:@"arrivato"] boolValue];
            }
            
            dispatch_group_leave(group);
            
        }];
        
    }
    
    
    // Here we wait for all the requests to finish
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Do whatever you need to do when all requests are finished
        NSLog(@"Finito le richieste al server");
        // mando l'array
        completion([final copy]);
    });
    
}

- (void)updateSelectedDate
{
    [self.viaggi removeAllObjects];
    [self caricaViaggi];
    
}

/* Apre la schermata di aggiunta prodotti */
- (void)addTrain:sender {
    [self performSegueWithIdentifier:@"addSegue" sender:sender];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections: pari al numero di viaggi di una giornata (i treni sono raggruppati in viaggi)
    return [self.viaggi count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // ogni sezione (e quindi viaggio) è composto dai treni del suo tragitto
    Viaggio *sezione = self.viaggi[section];
    return [sezione.tragitto count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 96;
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titolo;
    
    
    
    
    if([self.viaggi count] > 0) {
        Viaggio *viaggioSezione = [self.viaggi objectAtIndex:section];
        titolo = [NSString stringWithFormat:@"%@ | %@ → %@",viaggioSezione.durata,[viaggioSezione luogoPartenza],[viaggioSezione luogoArrivo]];
    }
    else return nil;
    
    return titolo;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"trenoCell";
    
    
    SalvatoTableViewCell *cell = (SalvatoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Viaggio *viaggio = [self.viaggi objectAtIndex:indexPath.section];
    
    cell.treno = [viaggio.tragitto objectAtIndex:indexPath.row];
    
    
    cell.partenzaL.text = cell.treno.partenza.nome;
    cell.arrivoL.text = cell.treno.arrivo.nome;
    
    cell.trenoL.text = [NSString stringWithFormat:@"%@ %@",cell.treno.categoria,cell.treno.numero];
    
    cell.orarioPL.text =  [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:cell.treno.orarioPartenza]];
    cell.orarioAL.text =  [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:cell.treno.orarioArrivo]];
    
    if([self.datepicker selectedIndex] == 0) {
        cell.ritardoL.text = [cell.treno stringaStatoTemporale];
    } else  cell.ritardoL.text = @"";
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SalvatoTableViewCell *cell  = (SalvatoTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"dettaglioTreno" sender:cell];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"dettaglioTreno"]) {
        
        SalvatoTableViewCell *trenocell = (SalvatoTableViewCell*) sender;
        
        DettaglioTrenoViewController *destination = (DettaglioTrenoViewController*) [segue destinationViewController];
        destination.treno = trenocell.treno;
        
        // dico al dettaglio se è il treno della giornata attuale o meno
        if([self.datepicker selectedIndex] == 0) destination.attuale = YES;
        else destination.attuale = NO;
        
        destination.dataTreno = self.datepicker.selectedDate;
        
        
    }
}



@end

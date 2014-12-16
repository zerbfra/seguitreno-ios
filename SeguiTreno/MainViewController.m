//
//  MainView.m
//  TrenoSmart
//
//  Created by Francesco Zerbinati on 04/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "MainViewController.h"
#import "DettaglioTrenoViewController.h"
#import "NewTrainController.h"



@implementation MainViewController


-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    // status bar bianca
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    
    [self.datepicker fillDatesFromCurrentDate:15];
    
    [self.datepicker selectDateAtIndex:0];
    
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    
    self.treniTable.delegate = self;
    self.treniTable.dataSource = self;
    self.treniTable.backgroundColor = BACKGROUND_COLOR;
    self.treniTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.datepicker addTarget:self action:@selector(updateSelectedDate) forControlEvents:UIControlEventValueChanged];
    
    self.viaggi = [NSMutableArray array];
    
    // rispondo alla notifica aggiornando tutti i viaggi
    [[NSNotificationCenter defaultCenter]   addObserver:self
                                               selector:@selector(caricaViaggi)
                                                   name:@"update"
                                                 object:nil];
    
    
    // aggiungo refresh sulla tabella
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.treniTable addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    

    [self caricaViaggi];

    
}

-(void) viewWillAppear:(BOOL)animated {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTrain:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [self.treniTable deselectRowAtIndexPath:[self.treniTable indexPathForSelectedRow] animated:YES];
}



-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    [self showDelete];
    
}

-(void) showDelete {

    // solo per fare l'animazione correttamente
    [self.treniTable beginUpdates];
    [self.treniTable endUpdates];

}



-(void) refresh {
    [self caricaViaggi:NO];
    [self.refreshControl endRefreshing];
}

-(void) caricaViaggi {
    [self caricaViaggi:YES];
}

-(void) caricaViaggi:(BOOL) localFirst {
    // siccome il metodo carica viaggi implica vari caricamenti dal DB, lo mando su un secondo thread
    [[ThreadHelper shared] executeInBackground:@selector(recuperaViaggiDB) of:self completion:^(BOOL success) {
        // qui sono di nuovo sul main thread
        NSLog(@"Ho caricato db");
        
        // se mi è specificato di dare subito un output do i dati locali (che poi aggiornerò)
        if(localFirst) {
        
        // Aggiorno tabella con un'animazione (con i dati locali)
        [UIView transitionWithView:self.treniTable
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^(void) {
                            [self.treniTable reloadData];
                        } completion:NULL];
        }
        
        // richiedo informazioni aggiuntive sui treni se sono quelli della giornata (quindi index = 0)
        if([self.datepicker selectedIndex] == 0) {
            NSLog(@"Recupero informazioni live...");
            [self requestGroupTrain:[self elencoTreni]  completion:^(NSArray *response) {
                // aggiorno per le informazioni recuperate dal server, con una piccola animazione
                [UIView transitionWithView:self.treniTable
                                  duration:0.2f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^(void) {
                                    [self.treniTable reloadData];
                                } completion:NULL];
            }];
        } else {
            NSLog(@"Stampo treni senza live...");
        }
    }];
}

// funzione per il recupero dei viaggi dal database, vengono chiaramente selezionati i viaggi della giornata selezionata
-(void) recuperaViaggiDB {
    
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
                
                Treno *trovato = [[Treno alloc] init];
                trovato.numero = [trenoSet objectForKey:@"numero"];
                
                trovato.idTreno = [trenoSet objectForKey:@"id"];
                

                Stazione *origine = [[Stazione alloc] init];
                origine.idStazione = [trenoSet objectForKey:@"idOrigine"];
                
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
    
}

// restituisce l'array dei treni presenti nella giornata selezionata
-(NSMutableArray*) elencoTreni {
    
    NSMutableArray* treni = [NSMutableArray array];
    
    for(Viaggio* viaggio in self.viaggi) {
        for(Treno* treno in viaggio.tragitto) {
            [treni addObject:treno];
        }
    }
    
    return treni;
}

// con un gruppo di dispatch, richiede le informazioni dei vari treni (dispatch_group per terminare tutto insieme)
-(void) requestGroupTrain:(NSMutableArray*) batch completion:(void (^)(NSArray *))completion {
    
    // creo un gruppo di dispatch
    dispatch_group_t group = dispatch_group_create();
    
    NSMutableArray *final = [NSMutableArray array];
    
    for(Treno *treno in batch)
    {
        
        dispatch_group_enter(group);
        
        [[APIClient sharedClient] requestWithPath:@"trovaTreno" andParams:@{@"numero":treno.numero,@"origine":treno.origine.idStazione,@"includiFermate":[NSNumber numberWithBool:false]} completion:^(NSDictionary *response) {

            for(NSDictionary *trenoDict in response) {
                // controllo che non sia stato restituito un null (può succedere in casi eccezzionali)
                if([NSNull null] != [trenoDict objectForKey:@"ritardo"]) {
                    treno.ritardo = [[trenoDict objectForKey:@"ritardo"] intValue];
                    treno.soppresso = [[trenoDict objectForKey:@"sopresso"] boolValue];
                    treno.arrivato = [[trenoDict objectForKey:@"arrivato"] boolValue];
                    treno.stazioneUltimoRilevamento = [trenoDict objectForKey:@"stazioneUltimoRilevamento"];
                    treno.nonDisponibile = false;
                } else {
                    treno.nonDisponibile = true;
                }
                
            }
            
            dispatch_group_leave(group);
            
        }];
        
    }
    
    
    //  qui aspetto che tutte le richieste son finite
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // quando tutte sono stase eseguite
        NSLog(@"Finito le richieste al server");
        // mando l'array
        completion([final copy]);
    });
    
}

// aggiornamento dovuto al fatto che cambio la scheda data
- (void)updateSelectedDate
{
    [self.viaggi removeAllObjects];
    [self caricaViaggi];
    
}

// apre la schermata di aggiunta prodotti
- (void)addTrain:sender {
    [self performSegueWithIdentifier:@"addSegue" sender:sender];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // numero di sezioni: pari al numero di viaggi di una giornata (i treni sono raggruppati in viaggi)
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

// imposta la grafica per l'header delle soluzioni viaggio
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    
    NSString *titolo;
    
    if([self.viaggi count] > 0) {
        Viaggio *viaggioSezione = [self.viaggi objectAtIndex:section];
        titolo = [NSString stringWithFormat:@"%@  %@ → %@",viaggioSezione.durata,[viaggioSezione luogoPartenza],[viaggioSezione luogoArrivo]];
    }
    
    UIView* head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];
 
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(3, 20, tableView.frame.size.width, 22)];
    headerView.backgroundColor = [UIColor lightGrayColor];
    
    [head addSubview:headerView];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 350, 22)];
    headerLabel.text = titolo;
    headerLabel.font = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    headerLabel.textColor = [UIColor whiteColor];

    [headerView addSubview:headerLabel];

    return head;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 42.0;
}

// il footer è dinamico quindi ha altezza diversa a seconda che siamo in modalità di modifica o meno
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    if(self.editing)
    return 38.0f;
    else return 0.1f;

}

// vista per il footer (pulsante cancella)
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    UIView *footer=[[UIView alloc] initWithFrame:CGRectMake(0.0f,0.0f,tableView.frame.size.width,38.0f)];
    footer.clipsToBounds = YES;
    
    
    footer.backgroundColor = [UIColor whiteColor];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 37, tableView.frame.size.width, 1)];
    lineView.backgroundColor = COLOR_WITH_RGB(231,231,231);
    [footer addSubview:lineView];

    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = section;
    
    
    [button setTitle:@"Cancella" forState:UIControlStateNormal];
    [button setTitleColor:RED forState:UIControlStateNormal];
    [button addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:button];

    button.frame = CGRectMake(5, 3, tableView.frame.size.width-10, 32);
    

    
    return footer;
    
    
}

// Metodo che gestisce il pulsante cancella e mostra un popup
-(void)deleteButtonPressed:(id)sender {
    // devo rimuovere il viaggio
    UIButton *button = (UIButton*) sender;
    Viaggio *viaggio = [self.viaggi objectAtIndex:button.tag];
    
    NSLog(@"Viaggio da cancellare: %@",viaggio.idViaggio);
    
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Cancella viaggio" message:@"Sei sicuro di voler cancellare il viaggio?" delegate:self cancelButtonTitle:@"Annulla" otherButtonTitles:@"Solo questa volta",@"Cancella tutti", nil];
    deleteAlert.tag = [viaggio.idViaggio intValue];
    [deleteAlert show];
    
    
}

// metodo che cancella una soluzione viaggio dato l'idViaggio
-(void) cancellaSoluzioni:(NSNumber*) idViaggio {
    
    NSString *query = [NSString stringWithFormat:@"SELECT idViaggio FROM ripetizioni where id = (SELECT id FROM ripetizioni  WHERE idViaggio = '%ld')",[idViaggio integerValue]];
    NSArray *idViaggi =  [[DBHelper sharedInstance] executeSQLStatement:query];
    
    for (NSDictionary* cancella in idViaggi) {
        
        NSNumber *idCancella = [cancella objectForKey:@"idViaggio"];
        
        [self cancellaViaggio:idCancella];
        // nel caso di rimozione di cancellazioni di tutti, pulisco anche il treno
        query = [NSString stringWithFormat:@"DELETE FROM treni WHERE id IN (SELECT idTreno FROM 'treni-viaggi' WHERE idViaggio = '%ld')",[idCancella integerValue]];
        [[DBHelper sharedInstance] executeSQLStatement:query];
        
    }
}

// cancella il viaggio (chiamata da quella sopra)
-(void) cancellaViaggio:(NSNumber*) idViaggio {
    
    NSString *query = [NSString stringWithFormat:@"DELETE FROM viaggi where id = '%ld'",[idViaggio integerValue]];
    [[DBHelper sharedInstance] executeSQLStatement:query];
    query =  [NSString stringWithFormat:@"DELETE FROM ripetizioni WHERE idViaggio = '%ld'",[idViaggio integerValue]];
    [[DBHelper sharedInstance] executeSQLStatement:query];
    query =  [NSString stringWithFormat:@"DELETE FROM 'treni-viaggi' WHERE idViaggio = '%ld'",[idViaggio integerValue]];
    [[DBHelper sharedInstance] executeSQLStatement:query];
    
}

// metodo che chiama i vari metodi a seconda che si sia premuto un bottone o l'altro
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // a seconda di cosa viene premuto cancello il viaggio corrispondente (intero salvato nel tag)
    NSNumber *tag = [NSNumber numberWithInteger:alertView.tag];
   
    SEL method;
    
    switch (buttonIndex) {
        case 1:
            method = @selector(cancellaViaggio:);
            break;
        case 2:
            method = @selector(cancellaSoluzioni:);
            break;
        default:
            return;
            break;
    }
    
    [[ThreadHelper shared] executeInBackground:method of:self withParam:tag completion:^(BOOL success) {
        NSLog(@"Cancellato tutto");
        [self caricaViaggi];
    }];
    
}

// imposta ogni cella graficamente
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"trenoCell";
    
    
    SalvatoTableViewCell *cell = (SalvatoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Viaggio *viaggio = [self.viaggi objectAtIndex:indexPath.section];
    
    cell.treno = [viaggio.tragitto objectAtIndex:indexPath.row];

    
    cell.partenzaL.text = cell.treno.partenza.nome;
    cell.arrivoL.text = cell.treno.arrivo.nome;
    
    cell.trenoL.text = [cell.treno stringaDescrizione];
    
    cell.orarioPL.text =  [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:cell.treno.orarioPartenza]];
    cell.orarioAL.text =  [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:cell.treno.orarioArrivo]];
    
    if([self.datepicker selectedIndex] == 0) {
        cell.ritardoL.text = [cell.treno stringaStatoTemporale];
        
        if(cell.treno.soppresso) cell.ritardoL.textColor = RED;
        
    } else  cell.ritardoL.text = @"";

    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    SalvatoTableViewCell *cell  = (SalvatoTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    // solo se ho informazioni dalle API lo rendo cliccabile, inoltre son cliccabili solo quelli del giorno stesso
    if(!cell.treno.nonDisponibile && !cell.treno.soppresso && [self.datepicker selectedIndex] == 0) {

        // attivo un indicatore che comunnica che sto lavorando per recuperare le info del treno
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicator.hidesWhenStopped = YES;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
        [activityIndicator startAnimating];
        [cell setUserInteractionEnabled:NO];

        // una volta che le info sono caricate mostro la nuova schermata con il dettaglio
        [cell.treno caricaInfoComplete:^{
            [self performSegueWithIdentifier:@"dettaglioTreno" sender:cell];
            [activityIndicator stopAnimating];
            [cell setUserInteractionEnabled:YES];
        }];
    }
    else [self.treniTable deselectRowAtIndexPath:indexPath animated:YES];
    
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
    
    
    if([[segue identifier] isEqualToString:@"addSegue"]) {
        
        UINavigationController *navController = segue.destinationViewController;
        NewTrainController *destination = (NewTrainController*)navController.topViewController;
        destination.dataIniziale = self.datepicker.selectedDate;
    }
}




@end

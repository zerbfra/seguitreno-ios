//
//  NewTrainController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 05/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "NewTrainController.h"


@interface NewTrainController ()

@end

@implementation NewTrainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // status bar bianca
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close:)];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(salvaTreno)];
    
    self.navigationItem.leftBarButtonItem = closeButton;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.view.backgroundColor = BACKGROUND_COLOR;
    
    
    self.viaggio = [[Viaggio alloc] init];
    
    self.trenoCompilato = FALSE;
    //self.ripetizioneSel = 0;
    
    self.viaggio.data = [[DateUtils shared] date:self.dataIniziale At:0];
    
    self.selettoreRipetizione.delegate = self;
    
    // giorni della ripetizione, inizialmente tutti a 0
    self.giorni = [NSMutableArray arrayWithObjects:@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil];
    
    self.soluzioneViaggio.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "]; // BUG IOS8.1
    
    [self.pickDataViaggio setDatePickerMode:UIDatePickerModeDate];
    [self.pickDataViaggio addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    self.pickDataViaggio.minimumDate = self.viaggio.data;
    self.pickDataViaggio.date = self.viaggio.data;
}

-(void)viewWillAppear:(BOOL)animated {
    
    if(self.viaggio.partenza.nome == nil) self.stazionePartenza.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "]; // BUG IOS8.1
    else self.stazionePartenza.detailTextLabel.text = self.viaggio.partenza.nome;
    
    if(self.viaggio.arrivo.nome == nil) self.stazioneDestinazione.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "]; // BUG IOS8.1
    else self.stazioneDestinazione.detailTextLabel.text = self.viaggio.arrivo.nome;
    
}

-(void) datePickerChanged:(UIDatePicker *)datePicker {
    self.viaggio.data = [[DateUtils shared] date:datePicker.date At:0];
}

// imposto sull'oggetto stazione P
- (void) impostaStazioneP:(Stazione *) stazioneP {
    self.viaggio.partenza = stazioneP;
}

// imposto sull'oggetto stazione A
- (void) impostaStazioneA:(Stazione *)stazioneA {
    self.viaggio.arrivo = stazioneA;
}

// imposta la soluzione selezionata
- (void) impostaSoluzione:(Viaggio *) soluzioneSelezionata {
    // imposto sull'oggetto stazione P
    self.viaggio = soluzioneSelezionata;
    // importo la data
    self.viaggio.data = [self.viaggio orarioPartenza];
    
    self.trenoCompilato = TRUE; // il treno è ora compilato
    
    [self.tableView reloadData];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"DATI VIAGGIO";
            break;
        case 1:
            if(!self.trenoCompilato) return @"QUANDO";
            else return [NSString stringWithFormat:@"VIAGGIO DEL %@",[[DateUtils shared] showDateMedium:self.viaggio.data]];
        case 2:
            return nil;
            break;
        case 3:
            return @"RIPETIZIONE";
            
            break;
        default:
            return nil;
            break;
    }
}

// metodo che invoca il metodo per salvare il treno in background
-(void) salvaTreno {
    
    if(self.trenoCompilato) {
        // siccome il metodo salva implica molte query lo mando su un secondo thread
        [[ThreadHelper shared] executeInBackground:@selector(salvaConGiorni) of:self completion:^(BOOL success) {}];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Seleziona un treno per salvarlo!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

-(void) salvaConGiorni {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF != %@", @"0"];
    
    NSArray *giorniDaRipetere = [self.giorni filteredArrayUsingPredicate:predicate];
    
    NSLog(@"%@",giorniDaRipetere);
    
    // setto la fine della ripetizione != nil se ho delle ripetizioni
    if([giorniDaRipetere count] > 0) [self setFineRipetizione];
    
    NSLog(@"FINE RIPETIZIONE: %@",self.viaggio.fineRipetizione);
    
    NSMutableArray *viaggiInseriti = [NSMutableArray array];
    
    NSInteger tsPartenza, tsArrivo;
    
    NSMutableArray *arrayPartenza = [NSMutableArray array], *arrayArrivo = [NSMutableArray array];
    
    NSArray *arrayPartenzaTemp;
    NSArray *arrayArrivoTemp;
    
    // aggiungo la data selezionata per il picker
    
    [arrayPartenza addObject:[self.viaggio orarioPartenza]];
    [arrayArrivo addObject:[self.viaggio orarioArrivo]];
    
    for(NSString *idGiorno in giorniDaRipetere) {
        
        NSInteger idG = [idGiorno intValue];
        
        if(self.viaggio.fineRipetizione != nil) {
            arrayPartenzaTemp = [[DateUtils shared] arrayOfNextWeekDays:idG startingFrom:[self.viaggio orarioPartenza] to:self.viaggio.fineRipetizione];
            arrayArrivoTemp = [[DateUtils shared] arrayOfNextWeekDays:idG startingFrom:[self.viaggio orarioPartenza] to:self.viaggio.fineRipetizione];
        }
        /*else {
         arrayPartenzaTemp = [[DateUtils shared] arrayOfNextWeekDays:idG startingFrom:[self.viaggio orarioPartenza] to:[self.viaggio orarioPartenza]];
         arrayArrivoTemp = [[DateUtils shared] arrayOfNextWeekDays:idG startingFrom:[self.viaggio orarioPartenza] to:[self.viaggio orarioArrivo]];
         }*/
        
        
        
        [arrayPartenza addObjectsFromArray:arrayPartenzaTemp];
        [arrayArrivo addObjectsFromArray:arrayArrivoTemp];
        
    }
    
    // SALVO VIAGGI
    // ciclo inserimento viaggi fino alla fine delle ripetizioni
    
    for(int i = 0; i < [arrayPartenza count]; i++) {
        
        tsPartenza = [[NSNumber numberWithDouble:[[arrayPartenza objectAtIndex:i] timeIntervalSince1970]] intValue];
        tsArrivo = [[NSNumber numberWithDouble:[[arrayArrivo objectAtIndex:i] timeIntervalSince1970]] intValue];
        
        NSString *query = [NSString stringWithFormat:@"INSERT INTO viaggi (nomePartenza,nomeArrivo, orarioPartenza,orarioArrivo,durata) VALUES ('%@','%@','%ld','%ld','%@')",self.viaggio.partenza.nome,self.viaggio.arrivo.nome,(long)tsPartenza,(long)tsArrivo,self.viaggio.durata];
        
        [[DBHelper sharedInstance] executeSQLStatement:query];
        
        NSString *dbViaggio =  [[[[DBHelper sharedInstance] executeSQLStatement:@"SELECT last_insert_rowid() AS id"] objectAtIndex:0] objectForKey:@"id"];
        NSLog(@"Viaggio %@ salvato: %@",dbViaggio,[[DateUtils shared] showDateAndHHmm:[arrayPartenza objectAtIndex:i]]);
        [viaggiInseriti addObject:dbViaggio];
    }
    
    [self salva:viaggiInseriti];
    
    
}

-(void) salvaConRipetizioneStandard {
    
    NSMutableArray *viaggiInseriti = [NSMutableArray array];
    
    NSInteger tsPartenza, tsArrivo;
    
    NSDate *nextPartenza = [self.viaggio orarioPartenza];
    NSDate *nextArrivo = [self.viaggio orarioArrivo];
    
    // SALVO VIAGGI
    // ciclo inserimento viaggi fino alla fine delle ripetizioni
    do {
        
        tsPartenza = [[NSNumber numberWithDouble:[nextPartenza timeIntervalSince1970]] intValue];
        tsArrivo = [[NSNumber numberWithDouble:[nextArrivo timeIntervalSince1970]] intValue];
        
        NSString *query = [NSString stringWithFormat:@"INSERT INTO viaggi (nomePartenza,nomeArrivo, orarioPartenza,orarioArrivo,durata) VALUES ('%@','%@','%ld','%ld','%@')",self.viaggio.partenza.nome,self.viaggio.arrivo.nome,(long)tsPartenza,(long)tsArrivo,self.viaggio.durata];
        
        [[DBHelper sharedInstance] executeSQLStatement:query];
        
        NSString *dbViaggio =  [[[[DBHelper sharedInstance] executeSQLStatement:@"SELECT last_insert_rowid() AS id"] objectAtIndex:0] objectForKey:@"id"];
        NSLog(@"Viaggio %@ salvato: %@",dbViaggio,[[DateUtils shared] showDateAndHHmm:self.viaggio.fineRipetizione]);
        [viaggiInseriti addObject:dbViaggio];
        
        if(self.viaggio.fineRipetizione != nil) {
            nextPartenza = [[DateUtils shared] getNexWeekDateFor:nextPartenza until:self.viaggio.fineRipetizione];
            nextArrivo = [[DateUtils shared] getNexWeekDateFor:nextArrivo until:self.viaggio.fineRipetizione];
        } else nextPartenza = nil;
        
    }
    while(nextPartenza != nil);
    
    [self salva:viaggiInseriti];
    
}

// Metodo per il salvataggio del treno (funzionamento in background)
-(void)salva:(NSArray*) viaggiInseriti {
    
    // salvo ripetizioni
    for (NSUInteger index = 0; index < viaggiInseriti.count; index++) {
        NSString *query = [NSString stringWithFormat:@"INSERT INTO ripetizioni (id,idViaggio) VALUES ('%@','%@')",viaggiInseriti[0],viaggiInseriti[index]];
        [[DBHelper sharedInstance] executeSQLStatement:query];
    }
    
    NSMutableArray *treniInseriti = [NSMutableArray array];
    
    // creo un gruppo di dispatch
    dispatch_group_t group = dispatch_group_create();
    
    
    // salvo tutti i treni
    for(Treno *toDb in self.viaggio.tragitto) {
        
        //entro
        dispatch_group_enter(group);
        
        NSString  *numero = toDb.numero;
        
        self.presenzaMezziNonTreno = false;
        
        [[APIClient sharedClient] requestWithPath:@"trovaTreno" andParams:@{@"numero":numero,@"includiFermate":[NSNumber numberWithBool:false]} completion:^(NSDictionary *response) {
            
            NSArray* resp = (NSArray*) response;
            
            // solo in questo caso ho qualcosa da analizzare
            if([resp count] > 0) {
                
                __block NSDictionary *trenoDict;
                
                // controllare se uno dei due contiene la stazione inserita dall'utente (partenza o arrivo inseriti controllo con fermate del treno)
                // di default metto lo 0, poi valuto
                trenoDict  = [resp objectAtIndex:0];
                
                if([resp count] > 1) {
                    NSLog(@"Treno non univoco: %@",numero);
                    [resp enumerateObjectsUsingBlock:^(NSDictionary *tPossibile, NSUInteger idx,BOOL *stop) {
                        
                        [[APIClient sharedClient] syncRequest:@"trovaFermateTreno" withParams:@{@"numero":numero,@"origine":[tPossibile objectForKey:@"idOrigine"]} andTimeout:20 completion:^(NSDictionary *response) {
                            NSArray *stringheStazioni = (NSArray*) response;
                            NSLog(@"%@",stringheStazioni);
                            for (NSString *stringa in stringheStazioni) {
                                if ([stringa caseInsensitiveCompare:self.viaggio.partenza.nome] == NSOrderedSame || [stringa caseInsensitiveCompare:self.viaggio.arrivo.nome] == NSOrderedSame) {
                                    // il treno alla posizione idx è quello corretto
                                    NSLog(@"Trovata corrispondenza stazioni - treno");
                                    trenoDict = [resp objectAtIndex:idx];
                                    *stop = true;
                                }
                            }
                        }];
                        
                    }];
                }
                
                Stazione *origine = [[Stazione alloc] init];
                Stazione *destinazione = [[Stazione alloc] init];
                origine.idStazione = [trenoDict objectForKey:@"idOrigine"];
                destinazione.idStazione = [trenoDict objectForKey:@"idDestinazione"];
                toDb.origine = origine;
                toDb.destinazione = destinazione;
                toDb.categoria = [trenoDict objectForKey:@"categoria"];
                
                
                NSInteger tsPartenza = [[NSNumber numberWithDouble:toDb.orarioPartenza] intValue];
                NSInteger tsArrivo = [[NSNumber numberWithDouble:toDb.orarioArrivo] intValue];
                
                
                NSString *query = [NSString stringWithFormat:@"INSERT INTO treni (numero,idOrigine,idDestinazione,categoria,nomePartenza,nomeArrivo,orarioPartenza,orarioArrivo) VALUES ('%@','%@','%@','%@','%@','%@','%ld','%ld')",toDb.numero,toDb.origine.idStazione,toDb.destinazione.idStazione,toDb.categoria,toDb.partenza.nome,toDb.arrivo.nome,(long)tsPartenza,(long)tsArrivo];
                
                [[DBHelper sharedInstance] executeSQLStatement:query];
                NSString *dbTreno =  [[[[DBHelper sharedInstance] executeSQLStatement:@"SELECT last_insert_rowid() AS id"] objectAtIndex:0] objectForKey:@"id"];
                
                [treniInseriti addObject:dbTreno];
                NSLog(@"Treno %@ salvato: %@",dbTreno,toDb.numero);
                
                
                // compilo la tabella che associa treni ai viaggi
                for (NSUInteger indexV = 0; indexV < viaggiInseriti.count; indexV++) {
                    for (NSUInteger indexT = 0; indexT < treniInseriti.count; indexT++) {
                        //NSLog(@"Inserisco viaggio-treno");
                        NSString *query = [NSString stringWithFormat:@"INSERT INTO 'treni-viaggi' (idViaggio,idTreno) VALUES ('%@','%@')",viaggiInseriti[indexV],treniInseriti[indexT]];
                        [[DBHelper sharedInstance] executeSQLStatement:query];
                    }
                    
                }
            } else {
                NSLog(@"Risultati del treno %@ vuoti",numero);
                self.presenzaMezziNonTreno = true;
            }
            
            //esco
            dispatch_group_leave(group);
            
            
        }];
        
    }
    
    // tutti finiti, quindi dico alla schermata principale (MainViewController) di aggiornare la grafica
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"Finito le richieste di salvataggio");
        
        if(self.presenzaMezziNonTreno) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Attenzione!" message:@"Alcuni dei mezzi di trasporto della tua tratta sono treni urbani oppure autobus, pertanto non sono stati aggiunti." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
        
        // invio la notifica globale che ho aggiunto dei treni
        [[NSNotificationCenter defaultCenter] postNotificationName:@"update" object:nil];
    });
    
    
}



#pragma mark - UITableView Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"selezionaStazione" sender:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
    }
    
    if(indexPath.section == 0 && indexPath.row == 1) {
        [self performSegueWithIdentifier:@"selezionaStazione" sender:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]];
    }
    
    
    if(indexPath.section == 1 && indexPath.row == 1) {
        
        if(self.viaggio.partenza != nil && self.viaggio.arrivo != nil) {
            
            if(![self.viaggio.partenza.idStazione isEqualToString:self.viaggio.arrivo.idStazione]) [self performSegueWithIdentifier:@"selezionaTreno" sender:nil];
            else {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Seleziona due stazioni diverse per una soluzione viaggio" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                [alertView show];
            }
        }
        else {
            NSLog(@"Selezionare stazioni!");
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Devi selezionare stazione di partenza e di arrivo per poter cercare un treno!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// metodo che chiude il modal view controller
-(void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 4;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            if(self.trenoCompilato) return [self.viaggio.tragitto count];
            else return 2;
        case 2:
            if(self.trenoCompilato) return 1;
            else return 0;
        case 3:
            return 1;
        default:
            return 0;
            break;
    }
    
}

// disegna le varie celle del tragitto
-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    
    if(indexPath.section == 1 && self.trenoCompilato) {
        
        static NSString *cellIdentifier = @"cellTragitto";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        
        Treno *trenoCell = self.viaggio.tragitto[indexPath.row];
        
        cell.textLabel.text = [trenoCell stringaDescrizione];
        cell.detailTextLabel.text = [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:trenoCell.orarioPartenza]];
        
        return cell;
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.identifier  isEqual: @"selezionaStazione"]) {
        // per selezionare la stazione
        SearchStazioneViewController *destination = (SearchStazioneViewController*)[segue destinationViewController];
        destination.delegate = self;
        destination.settaDestinazione = [sender tag];
        
    }
    
    if([segue.identifier  isEqual: @"selezionaTreno"]) {
        
        SoluzioneViaggioViewController *destination = (SoluzioneViaggioViewController*) [segue destinationViewController];
        //ogni richiesta viene fatta alla mezza del giorno (se devo fare richiesta "nuova" resetto)
        self.viaggio.data = [[DateUtils shared] date:self.viaggio.data At:0];
        destination.query = self.viaggio;
        
    }
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // se sono in fase di selezione data devo mostrare il datepicker quindi mi serve una cella più alta
    if(!self.trenoCompilato && indexPath.section == 1 && indexPath.row == 0) {
        return 180.0;
    }
    // altrimenti visualizzo i treni selezionati
    return 44;
}

// metodo che ridisegna il picker della data se si preme il cambio della soluzione
- (IBAction)ridisegnaPicker:(id)sender {
    
    self.trenoCompilato = FALSE;
    
    
    NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:
                                 [NSIndexPath indexPathForRow:0 inSection:1],
                                 [NSIndexPath indexPathForRow:1 inSection:1],
                                 nil];
    
    
    NSMutableArray *rows = [NSMutableArray array];
    
    for (int i = 0; i < [self.viaggio.tragitto count]; i++) [rows addObject:[NSIndexPath indexPathForRow:i inSection:1]];
    
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView insertRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    // rimuovo cella con opzione per il cambio soluzione
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

-(void)multiSelect:(MultiSelectSegmentedControl *)multiSelecSegmendedControl didChangeValue:(BOOL)value atIndex:(NSUInteger)index{
    
    int indexInt = (int)index+1;
    
    if (value) {
        // selezionato
        [self.giorni replaceObjectAtIndex:index withObject:[NSString stringWithFormat:@"%d",indexInt]];
        
    } else {
        // deselzionato
        [self.giorni replaceObjectAtIndex:index withObject:@"0"];
        
    }
    NSLog(@"%@",self.giorni);
    
    
    
}

-(void) setFineRipetizione {
    self.viaggio.fineRipetizione = [[DateUtils shared] addDays:60 toDate:self.viaggio.data];
}


@end

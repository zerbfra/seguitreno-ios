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
    self.ripetizioneSel = 0;
    
    self.viaggio.data = [[DateUtils shared] date:self.dataIniziale At:0];
    
    
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

    //aggiorno la fine ripetizione in base a quello che è selezionato
    [self gestisciRipetizione:self.ripetizioneSel];
    
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
        [[ThreadHelper shared] executeInBackground:@selector(salva) of:self completion:^(BOOL success) {}];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Seleziona un treno per salvarlo!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}

// Metodo per il salvataggio del treno (funzionamento in background)
-(void)salva {
    
    for(Treno *testDuplicati in self.viaggio.tragitto) {
        [[APIClient sharedClient] requestWithPath:@"trovaTreno" andParams:@{@"numero":testDuplicati.numero,@"includiFermate":[NSNumber numberWithBool:false]} completion:^(NSDictionary *response) {
            NSLog(@"%@",response);
            
            NSMutableArray *destinazioniPossibili = [NSMutableArray array];
            for(NSDictionary *trenoDict in response) {
                NSString *trenoStringa = [NSString stringWithFormat:@"Treno %@ per %@",[trenoDict objectForKey:@"numero"],[trenoDict objectForKey:@"destinazione"]];
                [destinazioniPossibili addObject:trenoStringa];
            }
            // se più treni compaiono con lo stesso numero, devo far selezionare quale è quello corretto
            if([response count] > 1) {
                // chiedo all'utente
                #warning problema treni doppi, come risolvere? chiedo all'utente?
                
            }
        }];
    }

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

        [[APIClient sharedClient] requestWithPath:@"trovaTreno" andParams:@{@"numero":numero,@"includiFermate":[NSNumber numberWithBool:false]} completion:^(NSDictionary *response) {
            
            for(NSDictionary *trenoDict in response) {
                Stazione *origine = [[Stazione alloc] init];
                Stazione *destinazione = [[Stazione alloc] init];
                origine.idStazione = [trenoDict objectForKey:@"idOrigine"];
                destinazione.idStazione = [trenoDict objectForKey:@"idDestinazione"];
                toDb.origine = origine;
                toDb.destinazione = destinazione;
                toDb.categoria = [trenoDict objectForKey:@"categoria"];
            }
            
            
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
            
            //esco
            dispatch_group_leave(group);
            
            
        }];
        
    }
    
    // tutti finiti, quindi dico alla schermata principale (MainViewController) di aggiornare la grafica
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"Finito le richieste di salvataggio");
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

- (IBAction)selezioneRipetizione:(UISegmentedControl *)sender {
    [self gestisciRipetizione:sender.selectedSegmentIndex];
}

-(void) gestisciRipetizione:(NSInteger) selezionato {
    
    switch (selezionato) {
        case 0:
            //NSLog(@"Mai");
            self.viaggio.fineRipetizione = nil;
            self.ripetizioneSel = 0;
            break;
        case 1:
            //NSLog(@"2 settimane");
            self.viaggio.fineRipetizione = [[DateUtils shared] addDays:7 toDate:self.viaggio.data];
            self.ripetizioneSel = 1;
            break;
        case 2:
            //NSLog(@"1 mese");
            self.viaggio.fineRipetizione = [[DateUtils shared] addDays:30 toDate:self.viaggio.data];
            self.ripetizioneSel = 2;
            break;
        case 3:
            //NSLog(@"3 mesi");
            self.viaggio.fineRipetizione = [[DateUtils shared] addDays:90 toDate:self.viaggio.data];
            self.ripetizioneSel = 3;
            break;
        case 4:
            //NSLog(@"6 mesi");
            self.viaggio.fineRipetizione = [[DateUtils shared] addDays:180 toDate:self.viaggio.data];
            self.ripetizioneSel = 4;
            break;
            
        default:
            break;
    }

}

@end

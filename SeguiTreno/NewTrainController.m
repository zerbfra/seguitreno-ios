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
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(salva)];
    
    self.navigationItem.leftBarButtonItem = closeButton;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.view.backgroundColor = BACKGROUND_COLOR;
    
    
    self.viaggio = [[Viaggio alloc] init];
    
    self.trenoCompilato = FALSE;
    self.ripetizioneSel = 0;

    self.viaggio.data = [[DateUtils shared] date:self.dataIniziale At:0];

    
    self.soluzioneViaggio.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "]; // BUG IOS8
    
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
    //NSLog(@"Salvo data: %@",self.viaggio.data);

}


- (void) impostaStazioneP:(Stazione *) stazioneP {
    // imposto sull'oggetto stazione P
    self.viaggio.partenza = stazioneP;
}
- (void) impostaStazioneA:(Stazione *)stazioneA {
    // imposto sull'oggetto stazione A
    self.viaggio.arrivo = stazioneA;
}

- (void) impostaSoluzione:(Viaggio *) soluzioneSelezionata {
    // imposto sull'oggetto stazione P
    self.viaggio = soluzioneSelezionata;
    // importo la data
    self.viaggio.data = [self.viaggio orarioPartenza];
    // orario selezionato
    self.soluzioneViaggio.detailTextLabel.text =  [[DateUtils shared] showHHmm:[self.viaggio orarioPartenza]];
    

    
    self.trenoCompilato = TRUE;
    
    NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:
                               
                                 [NSIndexPath indexPathForRow:1 inSection:1],
                                 nil];
    
    
    self.labelSoluzione.text = [NSString stringWithFormat:@"%@\n alle ore %@",[[DateUtils shared] showDateMedium:[self.viaggio orarioPartenza]],[[DateUtils shared] showHHmm:[self.viaggio orarioPartenza]]];
    

    
    [UIView animateWithDuration:0.3 animations:^() {
        self.selezionaAltro.alpha = 1.0;
        self.labelSoluzione.alpha = 1.0;
        self.pickDataViaggio.alpha = 0.0;
    }];
    
    [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];

    //aggiorno la fine ripetizione in base a quello che è selezionato
    [self gestisciRipetizione:self.ripetizioneSel];
    
}


-(void)salva {
    //NSLog(@"Preparo salvataggio treno...");
    if(self.trenoCompilato) {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray *viaggiInseriti = [NSMutableArray array];
    
    NSInteger tsPartenza, tsArrivo;
    
    NSDate *nextPartenza = [self.viaggio orarioPartenza];
    NSDate *nextArrivo = [self.viaggio orarioArrivo];
    
    // SALVO VIAGGI
    do {
        // ciclo inserimento viaggi fino alla fine delle ripetizioni
        
        tsPartenza = [[NSNumber numberWithDouble:[nextPartenza timeIntervalSince1970]] intValue];
        tsArrivo = [[NSNumber numberWithDouble:[nextArrivo timeIntervalSince1970]] intValue];
        
        NSString *query = [NSString stringWithFormat:@"INSERT INTO viaggi (nomePartenza,nomeArrivo, orarioPartenza,orarioArrivo,durata) VALUES ('%@','%@','%ld','%ld','%@')",self.viaggio.partenza.nome,self.viaggio.arrivo.nome,tsPartenza,tsArrivo,self.viaggio.durata];

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
    
    // salvo tutti i treni
    for(Treno *toDb in self.viaggio.tragitto) {
        
        NSString  *numero = toDb.numero;
        
        [[APIClient sharedClient] requestWithPath:@"trovaTreno" andParams:@{@"numero":numero,@"includiFermate":[NSNumber numberWithBool:false]} completion:^(NSArray *response) {
            //NSLog(@"Response: %@", response);
            
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
            
            
            NSString *query = [NSString stringWithFormat:@"INSERT INTO treni (numero,idOrigine,idDestinazione,categoria,nomePartenza,nomeArrivo,orarioPartenza,orarioArrivo) VALUES ('%@','%@','%@','%@','%@','%@','%ld','%ld')",toDb.numero,toDb.origine.idStazione,toDb.destinazione.idStazione,toDb.categoria,toDb.partenza.nome,toDb.arrivo.nome,tsPartenza,tsArrivo];
            
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
            
            // invio la notifica globale che ho aggiunto dei treni
            [[NSNotificationCenter defaultCenter] postNotificationName:@"update" object:nil];
            
            
        }];
        
    }
    } else {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Seleziona un treno per salvarlo!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    
    
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




-(void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 3;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if(section == 2) return 1;
    if(self.trenoCompilato && section == 1) return 1;
    return 2;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier  isEqual: @"selezionaStazione"]) {
        
        SearchStazioneViewController *destination = (SearchStazioneViewController*)[segue destinationViewController];
        destination.delegate = self;
        destination.settaDestinazione = [sender tag];
        
    }
    
    if([segue.identifier  isEqual: @"selezionaTreno"]) {
        
        SoluzioneViaggioViewController *destination = (SoluzioneViaggioViewController*) [segue destinationViewController];
        destination.query = self.viaggio;
        
    }
    
    
}


- (IBAction)ridisegnaPicker:(id)sender {
    
    self.trenoCompilato = FALSE;
    NSArray *deleteIndexPaths = [[NSArray alloc] initWithObjects:
                                 [NSIndexPath indexPathForRow:1 inSection:1],
                                 nil];
    

    [UIView animateWithDuration:0.3 animations:^() {
        self.selezionaAltro.alpha = 0.0;
        self.labelSoluzione.alpha = 0.0;
        self.pickDataViaggio.alpha = 1.0;
    }];
    
    [self.tableView insertRowsAtIndexPaths:deleteIndexPaths withRowAnimation:UITableViewRowAnimationFade];
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
            self.viaggio.fineRipetizione = [[DateUtils shared] addDays:14 toDate:self.viaggio.data];
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
    
    NSLog(@"%@",self.viaggio.fineRipetizione);
}

@end

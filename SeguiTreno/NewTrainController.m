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
    
    self.settimanaRipetizioni.delegate = self;
    
    [self setDate];
    self.refresh = true;
    
    self.soluzioneViaggio.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "]; // BUG IOS8
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    if(self.viaggio.partenza.nome == nil) self.stazionePartenza.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "]; // BUG IOS8
    else self.stazionePartenza.detailTextLabel.text = self.viaggio.partenza.nome;
    
    if(self.viaggio.arrivo.nome == nil) self.stazioneDestinazione.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "]; // BUG IOS8
    else self.stazioneDestinazione.detailTextLabel.text = self.viaggio.arrivo.nome;
    
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
    
    self.soluzioneViaggio.detailTextLabel.text =  [[DateUtils shared] showHHmm:[self.viaggio orarioPartenza]]; //[self.viaggio mostraOrario:self.viaggio.orarioPartenza];
    self.dataViaggio.detailTextLabel.text = [self formattaData:self.viaggio.orarioPartenza conOrario:NO eGiorno:YES];
}


-(void) setDate {
    
    self.dataViaggio.detailTextLabel.text = [self formattaData:nil conOrario:NO eGiorno:YES];
    // imposto sull'oggetto dataviaggio a oggi (esattamente alla mezza)
    self.viaggio.data = [self creaData];
    
}

-(void)salva {
    NSLog(@"Preparo salvataggio treno...");
    
    
    NSString *viaggioQuery = [NSString stringWithFormat:@"INSERT INTO viaggi (durata) VALUES ('%@')",self.viaggio.durata];
    [[DBHelper sharedInstance] executeSQLStatement:viaggioQuery];
    
    NSString *record =  [[[[DBHelper sharedInstance] executeSQLStatement:@"SELECT last_insert_rowid() AS id"] objectAtIndex:0] objectForKey:@"id"];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // salvo tutti i treni
    for(Treno *toDb in self.viaggio.tragitto) {
        
        NSString  *numero = toDb.numero;
        
        [[APIClient sharedClient] requestWithPath:@"trovaTreno" andParams:@{@"numero":numero,@"includiFermate":[NSNumber numberWithBool:false]} completion:^(NSArray *response) {
            NSLog(@"Response: %@", response);
            
            for(NSDictionary *trenoDict in response) {
                toDb.categoria = [trenoDict objectForKey:@"categoria"];
                Stazione *origine = [[Stazione alloc] init];
                Stazione *destinazione = [[Stazione alloc] init];
                //origine.nome = [trenoDict objectForKey:@"origine"];
                origine.idStazione = [trenoDict objectForKey:@"idOrigine"];
                destinazione.idStazione = [trenoDict objectForKey:@"idDestinazione"];
                toDb.origine = origine;
                toDb.destinazione = destinazione;
            }
            
            
            
            
            
            
            NSInteger tsPartenza, tsArrivo;
            // son costretto a inserire i nomi perchè trenitalia nelle soluzioni viaggio del tragitto non da gli ID ma i nomi
            // in ogni caso non sono utili in tale circostanza in quanto serviranno solo poi per essere visualizzati nella schermata principale
            // nel dettaglio completo del treno/viaggio verranno elencate le varie stazioni e solo in quel momento sarà utile l'idStazione.
            // Il server si occupa di recuperare la stazione di origine dato un numero treno, quindi nel dettaglio recupererò il tutto.
            
            NSString *nomePartenza = toDb.partenza.nome;
            NSString *nomeArrivo = toDb.arrivo.nome;
            
            NSDate *nextPartenza = [[DateUtils shared] dateFrom:toDb.orarioPartenza];
            NSDate *nextArrivo = [[DateUtils shared] dateFrom:toDb.orarioArrivo];
            
            //NSLog(@"nextpartenza %@",[self formattaData:[toDb datePartenza] conOrario:NO eGiorno:YES]);
            //NSLog(@"%@",[self formattaData:self.viaggio.fineRipetizione conOrario:NO eGiorno:YES]);
            
            do {
                // ciclo i treni fino alla fine delle ripetizioni
                NSLog(@"Salvo");
                
                
                tsPartenza = [[NSNumber numberWithDouble:[nextPartenza timeIntervalSince1970]] intValue];
                tsArrivo = [[NSNumber numberWithDouble:[nextArrivo timeIntervalSince1970]] intValue];
                
                NSString *query = [NSString stringWithFormat:@"INSERT INTO treni (numero,idSoluzione, nomePartenza,nomeArrivo,orarioPartenza,orarioArrivo, idOrigine, idDestinazione, categoria) VALUES ('%@','%@','%@','%@','%ld','%ld','%@','%@','%@')",numero,record, nomePartenza,nomeArrivo,tsPartenza,tsArrivo,toDb.origine.idStazione,toDb.destinazione.idStazione,toDb.categoria];
                
                [[DBHelper sharedInstance] executeSQLStatement:query];
                
                
                if(self.viaggio.fineRipetizione != nil) {
                    nextPartenza = [self getNexWeekDateFor:nextPartenza until:self.viaggio.fineRipetizione];
                    NSLog(@"ciclo: %@",[self formattaData:nextPartenza conOrario:YES eGiorno:YES]);
                    nextArrivo = [self getNexWeekDateFor:nextArrivo until:self.viaggio.fineRipetizione];
                } else nextPartenza = nil;
                
            }
            while(nextPartenza != nil);
            
        }];
        
    }
    
    /*
     
     // salvo tutti i treni
     for(Treno *toDb in self.viaggio.tragitto) {
     NSString  *numero = toDb.numero;
     NSInteger tsPartenza = [[NSNumber numberWithDouble:[[toDb datePartenza] timeIntervalSince1970]] intValue];
     NSInteger tsArrivo = [[NSNumber numberWithDouble:[[toDb dateArrivo] timeIntervalSince1970]] intValue];
     NSString *idOrigine = toDb.stazioneP.idStazione;
     NSString *idDestinazione = toDb.stazioneA.idStazione;
     
     NSString *query = [NSString stringWithFormat:@"INSERT INTO treni (numero,idOrigine,idDestinazione,timestamp) VALUES (%@,%@,%@,%ld)",toDb.numero,toDb.stazioneP.idStazione,toDb.stazioneA.idStazione,ts];
     [[DBHelper sharedInstance] executeSQLStatement:query];
     }
     
     // ROBA BUONA
     NSIndexSet *indexes = [self.settimanaRipetizioni selectedSegmentIndexes];
     NSMutableArray *array = [NSMutableArray array];
     [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
     [array addObject:@(idx)];
     }];
     NSLog(@"%@", array);
     
     [[DBHelper sharedInstance] executeSQLStatement:[NSString stringWithFormat:@"UPDATE calendario SET %@ = %d WHERE id = %@",[[DBHelper sharedInstance] dayFromNumber:index],[[NSNumber numberWithBool:value]intValue],self.viaggio.idViaggio]];
     */
    
    
    
}

-(NSDate*) getNexWeekDateFor:(NSDate*) date until:(NSDate*) finish {
    NSDateComponents *weekComponent = [[NSDateComponents alloc] init];
    [weekComponent setWeekOfYear:1];
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [theCalendar dateByAddingComponents:weekComponent toDate:[NSDate date] options:0];
    
    
    if ([nextDate compare:finish] == NSOrderedAscending) {
        NSLog(@"date1 is earlier than date2");
        return nextDate;
    } else {
        NSLog(@"finito");
        return nil;
    }
    
    
}


- (IBAction)openDateSelectionController:(NSIndexPath*)sender {
    RMDateSelectionViewController *dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
    dateSelectionVC.delegate = self;
    
    //You can enable or disable blur, bouncing and motion effects
    dateSelectionVC.disableBouncingWhenShowing = TRUE;
    dateSelectionVC.disableMotionEffects = TRUE;
    dateSelectionVC.disableBlurEffects = TRUE;
    
    
    dateSelectionVC.senderIndex = sender;
    
    dateSelectionVC.tintColor = GREEN;
    
    //You can access the actual UIDatePicker via the datePicker property
    
    dateSelectionVC.datePicker.datePickerMode = UIDatePickerModeDate;
    dateSelectionVC.datePicker.minuteInterval = 5;
    dateSelectionVC.datePicker.minimumDate = [NSDate date];
    dateSelectionVC.datePicker.date = [NSDate date];
    
    [dateSelectionVC show];
    
}

#pragma mark - RMDAteSelectionViewController Delegates
- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate {
    
    if(vc.senderIndex.section == 1) {
        
        self.dataViaggio.detailTextLabel.text = [self formattaData:aDate conOrario:NO eGiorno:YES];
        
        
    } else {
        NSString *dateString = [self formattaData:aDate conOrario:NO eGiorno:NO];
        //if(vc.senderIndex.row == 0) //self.inizioRipetizione.detailTextLabel.text = dateString;
        //else {
        NSLog(@"setto finerip");
        self.viaggio.fineRipetizione = aDate;
        self.fineRipetizione.detailTextLabel.text = dateString;
        // }
        
        
        
        
    }
    
    
    
    
    self.viaggio.data = [self creaData];
    
    
}

-(NSDate*) creaData {
    // imposto data viaggio effettivamente selezionata alla mezzanotte (in modo da avere i treni di tutta la giornata)
    
    NSDate *aDate = [NSDate date];
    
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:aDate];
    
    aDate = [gregorian dateFromComponents:dateComponents];
    return aDate;
}

-(NSString*) formattaData:(NSDate*) aDate conOrario:(BOOL) vediora eGiorno:(BOOL) vedigiorno {
    
    if(aDate == nil) aDate = [NSDate date];
    
    NSString *dateString;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    if(vedigiorno)[format setDateStyle:NSDateFormatterFullStyle];
    else [format setDateStyle:NSDateFormatterShortStyle];
    if(vediora) [format setTimeStyle:NSDateFormatterShortStyle];
    else [format setTimeStyle:NSDateFormatterNoStyle];
    
    dateString = [format stringFromDate:aDate];
    
    return dateString;
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc {
    //NSLog(@"Date selection was canceled");
    
}

#pragma mark - UITableView Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"selezionaStazione" sender:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
    }
    
    if(indexPath.section == 0 && indexPath.row == 1) {
        [self performSegueWithIdentifier:@"selezionaStazione" sender:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]];
    }
    
    
    if((indexPath.section == 1 && indexPath.row == 0) || (indexPath.section == 2 && (indexPath.row == 1 || indexPath.row == 2))) {
        [self openDateSelectionController:indexPath];
    }
    
    if(indexPath.section == 1 && indexPath.row == 1) {
        [self performSegueWithIdentifier:@"selezionaTreno" sender:nil];
    }
    
    
    if(indexPath.section == 3) [self openDateSelectionController:indexPath];
    
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)multiSelect:(MultiSelectSegmentedControl *)multiSelecSegmendedControl didChangeValue:(BOOL)value atIndex:(NSUInteger)index{
    
    
    if([self.settimanaRipetizioni.selectedSegmentIndexes count] > 0 && self.refresh) {
        [self.tableView reloadData];
        self.refresh = false;
    }
    
    if([self.settimanaRipetizioni.selectedSegmentIndexes count] == 0) {
        [self.tableView reloadData];
        self.refresh = true;
    }
    NSLog(@"%@",[self.settimanaRipetizioni selectedSegmentIndexes]);
    
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
    if([self.settimanaRipetizioni.selectedSegmentIndexes count] == 0) return 3;
    else return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if(section == 2) return 1;
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
        //destination.delegateNext = self;
        destination.query = self.viaggio;
        
    }
    
    
}


@end

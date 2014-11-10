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
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTrain:)];
    
    self.navigationItem.leftBarButtonItem = closeButton;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.view.backgroundColor = BACKGROUND_COLOR;
    
    // CAMBIARE TRENO CON SOLUZIONE VIAGGIO
    
    //self.treno = [[Treno alloc] init];
    self.viaggio = [[Viaggio alloc] init];
    
    self.settimanaRipetizioni.delegate = self;
    
    [self setDate];
    self.refresh = true;
    
    self.soluzioneViaggio.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "]; // BUG IOS8
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    if(self.viaggio.origine.nome == nil) self.stazionePartenza.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "]; // BUG IOS8
    else self.stazionePartenza.detailTextLabel.text = self.viaggio.origine.nome;
    
    if(self.viaggio.destinazione.nome == nil) self.stazioneDestinazione.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "]; // BUG IOS8
    else self.stazioneDestinazione.detailTextLabel.text = self.viaggio.destinazione.nome;
    
}

- (void) impostaStazioneP:(Stazione *) stazioneP {
    // imposto sull'oggetto stazione P
    self.viaggio.origine = stazioneP;
}
- (void) impostaStazioneA:(Stazione *)stazioneA {
    // imposto sull'oggetto stazione A
    self.viaggio.destinazione = stazioneA;
}

- (void) impostaSoluzione:(Viaggio *) soluzioneSelezionata {
    // imposto sull'oggetto stazione P
    self.viaggio = soluzioneSelezionata;
    
    self.soluzioneViaggio.detailTextLabel.text =  [self.viaggio mostraOrario:self.viaggio.orarioPartenza];
    self.dataViaggio.detailTextLabel.text = [self formattaData:self.viaggio.orarioPartenza conOrario:NO eGiorno:YES];
}


-(void) setDate {
    
    self.dataViaggio.detailTextLabel.text = [self formattaData:nil conOrario:NO eGiorno:YES];
    // imposto sull'oggetto dataviaggio a oggi (esattamente alla mezza)
    self.viaggio.data = [self creaData];
    
}

-(void)saveTrain:(id)sender {
    
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
        if(vc.senderIndex.row == 0) self.inizioRipetizione.detailTextLabel.text = dateString;
        else self.fineRipetizione.detailTextLabel.text = dateString;
        
        
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
            destination.delegateNext = self;
            destination.query = self.viaggio;
        
    }
    
    
}


@end

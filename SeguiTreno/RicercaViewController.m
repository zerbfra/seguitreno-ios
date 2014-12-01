//
//  RicercaViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 01/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "RicercaViewController.h"


@interface RicercaViewController ()

@end

@implementation RicercaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // status bar bianca
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    self.viaggio = [[Viaggio alloc] init];
    
    [self settaFasciaBaseOrario];
    

}

-(void) settaFasciaBaseOrario {
    
    //selezione del segmento (e della fascia oraria) a seconda del momento della giornata
    
    if([[DateUtils shared] date:[NSDate date] isBetweenDate:[[DateUtils shared] date:[NSDate date] At:0]  andDate:[[DateUtils shared] date:[NSDate date] At:12]]) {
        [self.fasciaOraria setSelectedSegmentIndex:0];
        self.viaggio.data = [[DateUtils shared] date:[NSDate date] At:0];
        
    }
    
    if([[DateUtils shared] date:[NSDate date] isBetweenDate:[[DateUtils shared] date:[NSDate date] At:12]  andDate:[[DateUtils shared] date:[NSDate date] At:18]]) {
        [self.fasciaOraria setSelectedSegmentIndex:1];
        self.viaggio.data = [[DateUtils shared] date:[NSDate date] At:12];
        
    }
    
    if([[DateUtils shared] date:[NSDate date] isBetweenDate:[[DateUtils shared] date:[NSDate date] At:18]  andDate:[[DateUtils shared] date:[NSDate date] At:24]]) {
        [self.fasciaOraria setSelectedSegmentIndex:2];
        self.viaggio.data = [[DateUtils shared] date:[NSDate date] At:18];
        
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    if(self.viaggio.partenza.nome == nil) self.stazionePartenza.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "]; // BUG IOS8.1
    else self.stazionePartenza.detailTextLabel.text = self.viaggio.partenza.nome;
    
    if(self.viaggio.arrivo.nome == nil) self.stazioneDestinazione.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:@" "]; // BUG IOS8.1
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 3;
            break;
        default:
            return 1;
            break;
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
    
    if(indexPath.section == 0 && indexPath.row == 2) {
       
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    
}



- (IBAction)search:(id)sender {
    
    [self performSegueWithIdentifier:@"cercaSoluzione" sender:nil];
    
}

- (IBAction)selezioneFascia:(id)sender {
    
    NSLog(@"Selezione fascia oraria");
    
    switch (self.fasciaOraria.selectedSegmentIndex)
    {
        case 0:
            self.viaggio.data = [[DateUtils shared] date:[NSDate date] At:0];
            break;
        case 1:
            self.viaggio.data = [[DateUtils shared] date:[NSDate date] At:12];
            break;
        case 2:
            self.viaggio.data = [[DateUtils shared] date:[NSDate date] At:18];
        default: 
            break; 
    }
    
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     if([segue.identifier  isEqual: @"selezionaStazione"]) {
         
         SearchStazioneViewController *destination = (SearchStazioneViewController*)[segue destinationViewController];
         destination.delegate = self;
         destination.settaDestinazione = [sender tag];
         
     }
     
     
     if([segue.identifier  isEqual: @"cercaSoluzione"]) {
         
         RisultatiViewController *destination = (RisultatiViewController*) [segue destinationViewController];
         destination.query = self.viaggio;
         destination.fascia = self.fasciaOraria.selectedSegmentIndex;
         
     }
     
 }


@end

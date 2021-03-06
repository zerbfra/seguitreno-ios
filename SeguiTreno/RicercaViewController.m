//
//  RicercaViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 01/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "RicercaViewController.h"
#define kOFFSET_FOR_KEYBOARD 200.0

@interface RicercaViewController ()

@end

@implementation RicercaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // status bar bianca
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    self.viaggio = [[Viaggio alloc] init];
    
    [self settaFasciaBaseOrario];
    
    
    // aggiungo il riconoscitore di tap sullo sfondo per chiudere la tastiera e per gestire lo slide della vista sui device piccoli (iphone 5 in giu)
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
}


-(void) keyboardWillShow:(NSNotification *) note {
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    if (self.view.frame.origin.y >= 0) [self setViewMovedUp:YES];
    
}

-(void) keyboardWillHide:(NSNotification *) note
{
    [self.view removeGestureRecognizer:self.tapRecognizer];
    if (self.view.frame.origin.y < 0) [self setViewMovedUp:NO];
}

// derivato da http://stackoverflow.com/questions/1126726/how-to-make-a-uitextfield-move-up-when-keyboard-is-present
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


// dismiss della tastiera se tappo in giro
-(void)didTapAnywhere: (UITapGestureRecognizer*) recognizer {
    [self.numeroTreno resignFirstResponder];
}


// selezione del segmento (e della fascia oraria) a seconda del momento della giornata
-(void) settaFasciaBaseOrario {

    
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


// dopo aver fatto i dovuti controlli (altrimenti mostra messaggio) cerca la soluzione
- (IBAction)search:(id)sender {
    
    if([self.numeroTreno.text length] > 0 || (self.viaggio.partenza != nil && self.viaggio.arrivo != nil)) [self performSegueWithIdentifier:@"cercaSoluzione" sender:nil];
    else {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Compila le stazioni o il numero treno" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    [self.numeroTreno resignFirstResponder];
    
}

// risponde al segmented controller
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
 
 // gestisce la navifazione per selezionare la stazione o per il bottone cerca
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     if([segue.identifier  isEqual: @"selezionaStazione"]) {
         
         SearchStazioneViewController *destination = (SearchStazioneViewController*)[segue destinationViewController];
         destination.delegate = self;
         destination.settaDestinazione = [sender tag];
         
     }
     
     
     if([segue.identifier  isEqual: @"cercaSoluzione"]) {
         
         RisultatiViewController *destination = (RisultatiViewController*) [segue destinationViewController];
         if([self.numeroTreno.text length] == 0) {
         destination.query = self.viaggio;
         destination.fascia = self.fasciaOraria.selectedSegmentIndex;
         } else {
             destination.numeroTreno = self.numeroTreno.text;
             NSLog(@"Numero treno");
         }
         
     }
     
 }


@end

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

@interface SoluzioneViaggioViewController ()

@end

@implementation SoluzioneViaggioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.soluzioniPossibili = [[NSMutableArray alloc] init];
    
    [self trovaSoluzioniTreno];
    
}

-(void) trovaSoluzioniTreno {
    
    NSNumber *ts = [NSNumber numberWithDouble:[self.trenoQuery.dataViaggio timeIntervalSince1970]];
    
    [[APIClient sharedClient] requestWithPath:@"soluzioniViaggio" andParams:@{@"partenza":[self.trenoQuery.stazioneP cleanId],@"arrivo":[self.trenoQuery.stazioneA cleanId],@"data":ts} completion:^(NSDictionary *responseDict) {
        //NSLog(@"Response: %@", responseDict);
        
        //NSMutableDictionary *fetched = [[NSMutableDictionary alloc] init]; // uso Trenitrovati
        
        
        for (NSDictionary *solDict in responseDict) {
            
            Viaggio  *soluzione = [[Viaggio alloc] init];
            
            Stazione *origine = [[Stazione alloc] init];
            Stazione *destinazione = [[Stazione alloc] init];
            
            origine.idStazione            = [self.trenoQuery.stazioneP cleanId];
            destinazione.idStazione       = [self.trenoQuery.stazioneA cleanId];
            
            origine.nome      = [solDict objectForKey:@"origine"];
            destinazione.nome = [solDict objectForKey:@"destinazione"];
            
            soluzione.origine = origine;
            soluzione.destinazione = destinazione;
            
            //soluzione.tragitto          = [solDict objectForKey:@"tragitto"];
            
            NSMutableArray *tmpTragitto = [[NSMutableArray alloc] init];
            
            for(NSDictionary *trenoDict in [solDict objectForKey:@"tragitto"]) {
                
                Treno *treno = [[Treno alloc] init];
                treno.numero = [trenoDict objectForKey:@"numero"];
                treno.orarioArrivo = [[trenoDict objectForKey:@"orarioArrivo"] doubleValue];
                treno.orarioPartenza = [[trenoDict objectForKey:@"orarioPartenza"] doubleValue];
                treno.categoria = [trenoDict objectForKey:@"categoria"];

                [tmpTragitto addObject:treno];
            }
            
            soluzione.tragitto = [tmpTragitto copy];
            
            soluzione.durata            = [solDict objectForKey:@"durata"];
            
            // aggiungo l'oggetto agli oggetti remoti
            [self.soluzioniPossibili addObject:soluzione];
            
        }
        
        [self.tableView reloadData];
        
        
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.soluzioniPossibili count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SoluzioneTableViewCell *cell = (SoluzioneTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"soluzioneViaggio" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.soluzione = [self.soluzioniPossibili objectAtIndex:indexPath.row];
    
    [cell disegna];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"dettaglioSoluzione" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    SoluzioneTableViewCell *senderCell = (SoluzioneTableViewCell*)sender;
    
    if([segue.identifier  isEqual: @"dettaglioSoluzione"]) {
        
        DettaglioSoluzioneViewController *destination = (DettaglioSoluzioneViewController*)[segue destinationViewController];

        destination.soluzione = senderCell.soluzione;
        
    }
    
    
}

@end

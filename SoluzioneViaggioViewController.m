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
    //NSNumber *ts = [NSNumber numberWithDouble:[self.query.data timeIntervalSince1970]];
    //NSLog(@"%@ %@ %@",[self.query.origine cleanId],[self.query.destinazione cleanId],ts);
    
}

-(void) trovaSoluzioniTreno {
    
    NSNumber *ts = [NSNumber numberWithDouble:[self.query.data timeIntervalSince1970]];

    [[APIClient sharedClient] requestWithPath:@"soluzioniViaggio" andParams:@{@"partenza":[self.query.partenza cleanId],@"arrivo":[self.query.arrivo cleanId],@"data":ts} completion:^(NSArray *response) {
        //NSLog(@"Response: %@", response);
        
        
        for (NSDictionary *solDict in response) {
            
            Viaggio  *soluzione = [[Viaggio alloc] init];
            
            Stazione *partenza = [[Stazione alloc] init];
            Stazione *arrivo = [[Stazione alloc] init];
            
            partenza.idStazione            = [self.query.partenza cleanId];
            arrivo.idStazione       = [self.query.arrivo cleanId];
            
            partenza.nome      = [solDict objectForKey:@"origine"];
            arrivo.nome = [solDict objectForKey:@"destinazione"];
            
            soluzione.partenza = partenza;
            soluzione.arrivo = arrivo;
            
            //soluzione.tragitto          = [solDict objectForKey:@"tragitto"];
            
            NSMutableArray *tmpTragitto = [[NSMutableArray alloc] init];
            
            for(NSDictionary *trenoDict in [solDict objectForKey:@"tragitto"]) {
                
                Treno *treno = [[Treno alloc] init];
                treno.numero = [trenoDict objectForKey:@"numero"];
                treno.orarioArrivo = [[trenoDict objectForKey:@"orarioArrivo"] doubleValue];
                treno.orarioPartenza = [[trenoDict objectForKey:@"orarioPartenza"] doubleValue];
                treno.categoria = [trenoDict objectForKey:@"categoria"];
                
                Stazione *stazioneP = [[Stazione alloc] init];
                stazioneP.nome = [trenoDict objectForKey:@"origine"];
                
                Stazione *stazioneA = [[Stazione alloc] init];
                stazioneA.nome = [trenoDict objectForKey:@"destinazione"];
                
                //[stazioneA formattaNome];
                //[stazioneP formattaNome];
                
                //stazioneA.idStazione = [[[[DBHelper sharedInstance] executeSQLStatement:[NSString stringWithFormat:@"SELECT id FROM stazioni WHERE nome = '%@'",stazioneA.nome]] objectAtIndex:0] objectForKey:@"id"];
                //stazioneP.idStazione = [[[[DBHelper sharedInstance] executeSQLStatement:[NSString stringWithFormat:@"SELECT id FROM stazioni WHERE nome = '%@'",stazioneP.nome]] objectAtIndex:0] objectForKey:@"id"];
                
                //NSLog(@"%@ %@",stazioneA.idStazione,stazioneP.idStazione);
                
                treno.partenza = stazioneP;
                treno.arrivo = stazioneA;

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
    
    // prima delle 6
    // tra le 6 e le 9
    // tra le 9 e le 12
    // tra le 12 e le 15
    // tra le 15 e le 18
    // tra le 18 e le 00
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    NSInteger numero;
    
    switch (section) {
        case 0:
            numero = [self numerosoluzioniTraOra:0 e:6];
            break;
        case 1:
            numero = [self numerosoluzioniTraOra:6 e:9];
            break;
        case 2:
            numero = [self numerosoluzioniTraOra:9 e:12];
            break;
        case 3:
            numero = [self numerosoluzioniTraOra:12 e:15];
            break;
        case 4:
            numero = [self numerosoluzioniTraOra:15 e:18];
            break;
        case 5:
            numero = [self numerosoluzioniTraOra:18 e:24];
            break;
        
        default:
            break;
    }
    
    return numero;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SoluzioneTableViewCell *cell = (SoluzioneTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"soluzioneViaggio" forIndexPath:indexPath];
    
    // Configure the cell...
    NSArray *soluzioniSezione;
    
    switch (indexPath.section) {
        case 0:
            soluzioniSezione = [self soluzioniTraOra:0 e:6];
            break;
        case 1:
            soluzioniSezione =[self soluzioniTraOra:6 e:9];
            break;
        case 2:
            soluzioniSezione =[self soluzioniTraOra:9 e:12];
            break;
        case 3:
            soluzioniSezione =[self soluzioniTraOra:12 e:15];
            break;
        case 4:
            soluzioniSezione =[self soluzioniTraOra:15 e:18];
            break;
        case 5:
            soluzioniSezione =[self soluzioniTraOra:18 e:24];
            break;
            
        default:
            break;
    }
    
    cell.soluzione = [soluzioniSezione objectAtIndex:indexPath.row];
    
    [cell disegna];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sezione;
    
    // prima delle 6
    // tra le 6 e le 9
    // tra le 9 e le 12
    // tra le 12 e le 15
    // tra le 15 e le 18
    // tra le 18 e le 00
    
    switch (section) {
        case 0:
            sezione = @"Prima delle 6";
            break;
        case 1:
            sezione = @"Tra le 6 e le 9";
            break;
        case 2:
            sezione = @"Tra le 9 e le 12";
            break;
        case 3:
            sezione = @"Tra le 12 e le 15";
            break;
        case 4:
            sezione = @"Tra le 15 e le 18";
            break;
        case 5:
            sezione = @"Dopo le 18";
            break;
            
        default:
            break;
    }
    return sezione;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"dettaglioSoluzione" sender:[self.tableView cellForRowAtIndexPath:indexPath]];
    
}

#pragma mark - Funzioni ausiliari per le date e soluzioni viaggio


-(NSArray*)soluzioniTraOra:(NSInteger) inizio e:(NSInteger) fine {
    
    NSDate *dataInizio = [[DateUtils shared] date:self.query.data At:inizio]; //[self todayAt:inizio];
    NSDate *dataFine = [[DateUtils shared] date:self.query.data At:fine];
    
    NSMutableArray *viaggiCompresi = [[NSMutableArray alloc] init];
    
    for(Viaggio* soluzione in self.soluzioniPossibili) {
        NSDate *partenza = [soluzione orarioPartenza];
        
        if([[DateUtils shared] date:partenza isBetweenDate:dataInizio andDate:dataFine]) [viaggiCompresi addObject:soluzione];
    }
    return viaggiCompresi;
}

-(NSInteger)numerosoluzioniTraOra:(NSInteger) inizio e:(NSInteger) fine {
    
    return [[self soluzioniTraOra:inizio e:fine] count];
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    SoluzioneTableViewCell *senderCell = (SoluzioneTableViewCell*)sender;
    
    if([segue.identifier  isEqual: @"dettaglioSoluzione"]) {
        
        DettaglioSoluzioneViewController *destination = (DettaglioSoluzioneViewController*)[segue destinationViewController];
        NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;

        destination.delegate = [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
        destination.soluzione = senderCell.soluzione;
        
    }
    
    
}

@end

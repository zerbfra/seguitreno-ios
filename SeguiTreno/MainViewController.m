//
//  MainView.m
//  TrenoSmart
//
//  Created by Francesco Zerbinati on 04/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController


-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    // status bar bianca
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    self.automaticallyAdjustsScrollViewInsets = NO;
    

    
  
    
    [self.datepicker fillDatesFromCurrentDate:15];
    
    [self.datepicker selectDateAtIndex:0];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTrain:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.treniTable.delegate = self;
    self.treniTable.dataSource = self;
    self.treniTable.backgroundColor = BACKGROUND_COLOR;
    self.treniTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.datepicker addTarget:self action:@selector(updateSelectedDate) forControlEvents:UIControlEventValueChanged];
    
    self.viaggi = [NSMutableArray array];
    [self caricaViaggi];

    
}

-(void) caricaViaggi {
    
    NSInteger start,end;
    
    if(self.datepicker.selectedDate == nil) {
        start = [[DateUtils shared] timestampFrom:[[DateUtils shared] date:[NSDate date] At:0]];
        end = [[DateUtils shared] timestampFrom:[[DateUtils shared] date:[NSDate date] At:24]];
    }
    else {
        start = [[DateUtils shared] timestampFrom:[[DateUtils shared] date:self.datepicker.selectedDate At:0]];
        end = [[DateUtils shared] timestampFrom:[[DateUtils shared] date:self.datepicker.selectedDate At:24]];
    }
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM viaggi WHERE id IN  (SELECT idSoluzione FROM treni WHERE orarioPartenza BETWEEN '%tu' AND '%tu' GROUP BY idSoluzione)",start,end];
    NSLog(@"%@",query);

    NSArray *dbViaggi = [[DBHelper sharedInstance] executeSQLStatement:query];
    

    

    
    //NSLog(@"%@",[[DateUtils shared] showDateFull:self.datepicker.selectedDate]);
    
    for (NSDictionary* viaggoSet in dbViaggi) {
        Viaggio *viaggio = [[Viaggio alloc] init];
        viaggio.idViaggio = [viaggoSet objectForKey:@"id"];
        viaggio.durata = [viaggoSet objectForKey:@"durata"];
        
        NSLog(@"%@",viaggio.idViaggio);
        
        //Viaggio *viaggio = [[Viaggio alloc] init];
        
        NSString*stmt = [NSString stringWithFormat:@"SELECT * FROM treni WHERE idSoluzione = '%@' AND orarioPartenza BETWEEN '%tu' AND '%tu' ORDER BY orarioPartenza",viaggio.idViaggio,start,end];
        NSArray *treni = [[DBHelper sharedInstance] executeSQLStatement:stmt];
        NSLog(@"%@",stmt);
        NSMutableArray *tragitto = [NSMutableArray array];
        
        for (NSDictionary* trenoSet in treni) {
            
            //viaggio.idViaggio = [trenoSet objectForKey:@"idSoluzione"];
            
            Treno *trovato = [[Treno alloc] init];
            trovato.numero = [trenoSet objectForKey:@"numero"];
            
            //NSLog(@"Treno: %@",trovato.numero);
            
            Stazione *origine = [[Stazione alloc] init];
            origine.idStazione = [trenoSet objectForKey:@"idOrigine"];
            //Stazione *destinazione = [[Stazione alloc] init];
            //destinazione.idStazione = [trenoSet objectForKey:@"idDestinazione"];
            
            trovato.origine = origine;
            
            Stazione *partenza = [[Stazione alloc] init];
            partenza.nome = [trenoSet objectForKey:@"nomePartenza"];
            
            
            
            Stazione *arrivo = [[Stazione alloc] init];
            arrivo.nome = [trenoSet objectForKey:@"nomeArrivo"];
            
            trovato.partenza = partenza;
            trovato.arrivo = arrivo;
            
            trovato.orarioPartenza = [[trenoSet objectForKey:@"orarioPartenza"] intValue];
            trovato.orarioArrivo = [[trenoSet objectForKey:@"orarioArrivo"] intValue];

            [tragitto addObject:trovato];
            
        }
        
        viaggio.tragitto = tragitto;
        [self.viaggi addObject:viaggio];
    }
    
    NSLog(@"Tutti i viaggi caricati");
    //NSLog(@"COUNTER %tu",[self.viaggi count]);

    // Aggiorno tabella con un'animazione
    [UIView transitionWithView:self.treniTable
                      duration:0.2f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^(void) {
                        [self.treniTable reloadData];
                    } completion:NULL];

}


- (void)updateSelectedDate
{
    [self.viaggi removeAllObjects];
    //NSLog(@"COUNTER %tu",[self.viaggi count]);
    [self caricaViaggi];
    
}

/* Apre la schermata di aggiunta prodotti */
- (void)addTrain:sender {
    [self performSegueWithIdentifier:@"addSegue" sender:sender];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections: pari al numero di viaggi di una giornata (i treni sono raggruppati in viaggi)
    return [self.viaggi count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // ogni sezione (e quindi viaggio) è composto dai treni del suo tragitto
    Viaggio *sezione = self.viaggi[section];
    return [sezione.tragitto count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 120;
    
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *titolo;
    

    

    if([self.viaggi count] > 0) {
        Viaggio *viaggioSezione = [self.viaggi objectAtIndex:section];
        titolo = [NSString stringWithFormat:@"%@ | %@ → %@",viaggioSezione.durata,[viaggioSezione luogoPartenza],[viaggioSezione luogoArrivo]];
    }
        else return nil;
    
    return titolo;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"trenoCell";

    
    SalvatoTableViewCell *cell = (SalvatoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Viaggio *viaggio = [self.viaggi objectAtIndex:indexPath.section];
    
    cell.treno = [viaggio.tragitto objectAtIndex:indexPath.row];
    
    
    cell.partenzaL.text = cell.treno.partenza.nome;
    cell.arrivoL.text = cell.treno.arrivo.nome;
    
    cell.trenoL.text = cell.treno.numero;
    
    cell.orarioPL.text =  [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:cell.treno.orarioPartenza]];
    cell.orarioAL.text =  [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:cell.treno.orarioArrivo]];

    
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end

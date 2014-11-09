//
//  DettaglioSoluzioneViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 08/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "DettaglioSoluzioneViewController.h"
#import "DettaglioSoluzioneTableViewCell.h"

@interface DettaglioSoluzioneViewController ()

@end

@implementation DettaglioSoluzioneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.orarioP.text = [self.soluzione mostraData:[self.soluzione orarioPartenza]];
    self.orarioA.text = [self.soluzione mostraData:[self.soluzione orarioArrivo]];
    
    self.stazioneP.text = self.soluzione.origine.nome;
    self.stazioneA.text = self.soluzione.destinazione.nome;
    
    self.durataSoluzione.text = self.soluzione.durata;
    
    self.numeroCambi.text = [NSString stringWithFormat:@"%lu",[self.soluzione numeroCambi]];
    
    //self.navigationItem.rightBarButtonItem = self.;
    
   
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Usa" style:UIBarButtonItemStyleDone target:self action:@selector(confirmSolution:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;

    
    
    
}

-(void)confirmSolution:(id) sender {
    NSLog(@"Salvataggio soluzione");
    [self.delegate impostaSoluzione:self.soluzione];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Una sezione per ogni cambio
    return [self.soluzione.tragitto count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DettaglioSoluzioneTableViewCell *cell = (DettaglioSoluzioneTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cellTreno" forIndexPath:indexPath];
    
    //cell.treno = [self.treni objectAtIndex:indexPath.section];
    cell.treno = [self.soluzione.tragitto objectAtIndex:indexPath.section];
    
    
    cell.stazioneP.text = cell.treno.stazioneP.nome;
    cell.stazioneA.text = cell.treno.stazioneA.nome;
    
    cell.orarioP.text = [cell.treno mostraOrario:[cell.treno datePartenza]];
    cell.orarioA.text = [cell.treno mostraOrario:[cell.treno dateArrivo]];
    // Configure the cell...
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    Treno *tmp = self.soluzione.tragitto[section];
    
    return [NSString stringWithFormat:@"Treno %@",tmp.numero];
}

/*
 -(void) getDatiTreni {
 
 
 NSArray *numeriTreno = [self.soluzione jsonCompatibile];
 
 [[APIClient sharedClient] requestWithPath:@"trovaTreniTratta" andParams:@{@"tratta":numeriTreno,@"includiFermate":[NSNumber numberWithBool:false]} completion:^(NSArray *response) {
 NSLog(@"Response: %@", response);
 
 
 //NSDictionary *trenoDict = [response objectAtIndex:0];
 NSInteger index = 0;
 
 for(NSDictionary *trenoDict in response) {
 
 Treno *resp = [self.soluzione.tragitto objectAtIndex:index];
 
 
 resp.numero = resp.numero;//[trenoDict objectForKey:@"numero"];
 
 Stazione *stazioneP = [[Stazione alloc] init];
 //stazioneP.idStazione = resp.stazioneP.idStazione;//[trenoDict objectForKey:@"idOrigine"];
 stazioneP.nome = resp.stazioneP.nome; //[trenoDict objectForKey:@"origine"];
 
 Stazione *stazioneA = [[Stazione alloc] init];
 //stazioneA.idStazione = [trenoDict objectForKey:@"idDestinazione"];
 stazioneA.nome = resp.stazioneA.nome; //[trenoDict objectForKey:@"destinazione"];
 
 [stazioneP formattaNome];
 [stazioneA formattaNome];
 
 resp.stazioneP = stazioneP;
 resp.stazioneA = stazioneA;
 
 resp.compDurata = [trenoDict objectForKey:@"compDurata"];
 
 resp.orarioArrivo =  resp.orarioArrivo; //[[trenoDict objectForKey:@"orarioArrivo"] doubleValue];
 resp.orarioPartenza = resp.orarioPartenza; //[[trenoDict objectForKey:@"orarioPartenza"] doubleValue];
 resp.categoria = [trenoDict objectForKey:@"categoria"];
 
 
 
 [self.treni addObject:resp];
 index++;
 }
 NSLog(@"TRENI: %@",self.treni);
 [self.tableView reloadData];
 
 }];
 
 
 
 
 
 
 
 }
 */

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

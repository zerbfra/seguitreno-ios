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
    
    self.orarioP.text = [[DateUtils shared] showDateAndHHmm:[self.soluzione orarioPartenza]]; // [self.soluzione mostraData:[self.soluzione orarioPartenza]];
    self.orarioA.text = [[DateUtils shared] showDateAndHHmm:[self.soluzione orarioArrivo]];// [self.soluzione mostraData:[self.soluzione orarioArrivo]];
    

    
    self.stazioneP.text = self.soluzione.partenza.nome;
    self.stazioneA.text = self.soluzione.arrivo.nome;
    

    
    self.durataSoluzione.text = self.soluzione.durata;
    
    self.numeroCambi.text = [NSString stringWithFormat:@"%lu",[self.soluzione numeroCambi]];
    
    
   
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Usa" style:UIBarButtonItemStyleDone target:self action:@selector(confirmSolution:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;

    /*
     NSArray *numeriTreno = [self.soluzione jsonCompatibile];
    [[APIClient sharedClient] requestWithPath:@"trovaCambio" andParams:@{@"tratta":numeriTreno} completion:^(NSArray *response) {
        NSLog(@"Response: %@", response);
        // se cambi = 0 (diretto) prosegui
        // se cambi = 3 beccali tutti
        // se cambi = 3 o qualsiasi altra cifra ma più opzioni scegli la prima 
        
    }];
     */
    
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
    
    cell.stazioneP.text = cell.treno.partenza.nome;
    cell.stazioneA.text = cell.treno.arrivo.nome;
    
    NSDate* orarioPartenza = [[DateUtils shared] dateFrom:cell.treno.orarioPartenza];
    NSDate* orarioArrivo = [[DateUtils shared] dateFrom:cell.treno.orarioArrivo];
    
    cell.orarioP.text = [[DateUtils shared] showHHmm:orarioPartenza];   //[cell.treno mostraOrario:[cell.treno datePartenza]];
    cell.orarioA.text = [[DateUtils shared] showHHmm:orarioArrivo];  //[cell.treno mostraOrario:orarioArrivo];
    // Configure the cell...
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    Treno *tmp = self.soluzione.tragitto[section];
    
    return [tmp stringaDescrizione];
}


@end

//
//  DettaglioTrenoViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 17/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "DettaglioTrenoViewController.h"
#import "FermataTableViewCell.h"
#import "JourneyProgressView.h"

@interface DettaglioTrenoViewController ()

@end

@implementation DettaglioTrenoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    // aggiungo refresh sulla tabella
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl setTintColor:GREEN];
    
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:[self.treno stringaDescrizione]
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(flipView)];
    self.navigationItem.rightBarButtonItem = flipButton;
    

    [self setData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

-(void) flipView {
    
}

-(void) refresh {
    [self.refreshControl endRefreshing];
    //[self loadInfo];
}


-(void) loadInfo {
    
    NSLog(@"%@",self.treno.origine.idStazione);
  //  [SVProgressHUD setForegroundColor:GREEN];
   // [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
   // [SVProgressHUD show];

    
    
    [[APIClient sharedClient] requestWithPath:@"trovaTreno" andParams:@{@"numero":self.treno.numero,@"origine":self.treno.origine.idStazione,@"includiFermate":[NSNumber numberWithBool:true]} completion:^(NSArray *response) {
        //NSLog(@"Response: %@", response);
        
        for(NSDictionary *trenoDict in response) {
            Stazione *origine = [[Stazione alloc] init];
            Stazione *destinazione = [[Stazione alloc] init];
            origine.idStazione = [trenoDict objectForKey:@"idOrigine"];
            origine.nome =  [trenoDict objectForKey:@"origine"];
            destinazione.idStazione = [trenoDict objectForKey:@"idDestinazione"];
            destinazione.nome =  [trenoDict objectForKey:@"destinazione"];
            [origine formattaNome];
            [destinazione formattaNome];
            self.treno.origine = origine;
            self.treno.destinazione = destinazione;
            self.treno.categoria = [trenoDict objectForKey:@"categoria"];
            self.treno.stazioneUltimoRilevamento = [trenoDict objectForKey:@"stazioneUltimoRilevamento"];
            self.treno.oraUltimoRilevamento = [trenoDict objectForKey:@"oraUltimoRilevamento"];
            
            self.treno.orarioArrivo = [[trenoDict objectForKey:@"orarioArrivo"] doubleValue];
            self.treno.orarioPartenza = [[trenoDict objectForKey:@"orarioPartenza"] doubleValue];
            self.treno.ritardo = [[trenoDict objectForKey:@"ritardo"] integerValue];
            
            self.treno.arrivato = [[trenoDict objectForKey:@"arrivato"] boolValue];
            self.treno.soppresso = [[trenoDict objectForKey:@"soppresso"] boolValue];
            
            NSDictionary *fermateDict = [trenoDict objectForKey:@"fermate"];
            
            NSMutableArray *fermateArray = [NSMutableArray array];
            
            for(NSDictionary *fermate in fermateDict) {
                
                
                Fermata *fermata = [[Fermata alloc] init];
                
                fermata.binarioEffettivo = [fermate objectForKey:@"binarioProgrammato"];
                fermata.binarioProgrammato = [fermate objectForKey:@"binarioEffettivo"];
                
                if([fermata.binarioEffettivo isEqualToString:@""]) fermata.binarioEffettivo = nil;
                if([fermata.binarioProgrammato isEqualToString:@""]) fermata.binarioProgrammato = nil;
                
                fermata.orarioProgrammato = [[fermate objectForKey:@"programmata"] doubleValue];
                fermata.raggiunta = [[fermate objectForKey:@"raggiunta"] boolValue];
                
                fermata.orarioEffettivo = [[fermate objectForKey:@"effettiva"] doubleValue];
                
                fermata.progressivo = [[fermate objectForKey:@"progressivo"] intValue];
                
                
                if(fermata.raggiunta == true) {
                    fermata.orarioEffettivo = [[fermate objectForKey:@"effettiva"] doubleValue]; // caso i cui sia effettiva (e quindi treno arrivato li)
                }
                else  {
                    fermata.orarioEffettivo = fermata.orarioProgrammato + self.treno.ritardo*60; // caso in cui non cè effettiva, stimo l'orario con il ritardo
                    
                }
                
                
                
                NSDictionary *stazioneDict = [fermate objectForKey:@"stazione"];
                Stazione *stazFermata = [[Stazione alloc] init];
                stazFermata.idStazione = [stazioneDict objectForKey:@"id"];
                stazFermata.nome = [stazioneDict objectForKey:@"nome"];
                // non forniti da questo JSON (rallenterebbero di molto le prestazioni del server)
                //stazFermata.lat = [[stazioneDict objectForKey:@"lat"] floatValue];
                //stazFermata.lon = [[stazioneDict objectForKey:@"lon"] floatValue];
                [stazFermata formattaNome];
                
                fermata.stazione = stazFermata;
                
                [fermateArray addObject:fermata];
                
            }
            
            self.treno.fermate = fermateArray;
            
            
        }
        
        [self setData];
       // [SVProgressHUD dismiss];
        
        
        
    }];

}

-(void) setData {
    
    if(self.attuale) {
    
    Stazione *rilevamento = [[Stazione alloc] init];
    rilevamento.nome = self.treno.stazioneUltimoRilevamento;

    if([rilevamento.nome isEqualToString:@"--"]) self.ultimoRilevamento.text = @"NON ANCORA PARTITO";
    else {
        if(self.treno.arrivato) self.ultimoRilevamento.text = @"ARRIVATO";
        else self.ultimoRilevamento.text = [NSString stringWithFormat:@"RILEVATO A %@",rilevamento.nome];

    }
    self.ritardo.text = [self.treno stringaRitardo];
    
    } else {
        self.ultimoRilevamento.text = @"NON ANCORA PARTITO";
        // siccome avrò impostata una data, visualizzo quella
        self.ritardo.text = [[DateUtils shared] showDateMedium:self.dataTreno];
    }
    
    self.orarioA.text = [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:self.treno.orarioArrivo]];
    self.orarioP.text = [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:self.treno.orarioPartenza]];
    
    self.stazioneP.text = self.treno.origine.nome;
    self.stazioneA.text = self.treno.destinazione.nome;
    

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    //[self.tableView reloadData];
    
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
    return [self.treno.fermate count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 70;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FermataTableViewCell *cell = (FermataTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cellFermata" forIndexPath:indexPath];
    
    cell.fermata = self.treno.fermate[indexPath.row];
    
    if(!self.attuale) cell.fermata.raggiunta = FALSE; // sicuramente non raggiunta in quanto treno non attuale
    
    // cancello l'immagine precedente a causa della reusable cell ;)
    [self deleteSubviews:cell.progressView];
    JourneyProgressView *timeline = [[JourneyProgressView alloc] initWithRow:(int)indexPath.row andMax:(int)[self.treno.fermate count]-1 andCurrentStatus:cell.fermata.raggiunta andFrame:cell.progressView.frame];
    [cell.progressView addSubview:timeline];

    
    cell.nomeFermata.text = cell.fermata.stazione.nome;
    cell.orarioProgrammato.text = [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:cell.fermata.orarioProgrammato]];
    cell.orarioEffettivo.text = [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:cell.fermata.orarioEffettivo]];
    cell.orarioEffettivo.textColor = cell.fermata.raggiunta == TRUE ? GREEN : DARKGREY;
    
    if(cell.fermata.binarioEffettivo == nil && cell.fermata.binarioProgrammato != nil) cell.binario.text = [NSString stringWithFormat:@"BINARIO %@",cell.fermata.binarioProgrammato];
    else if(cell.fermata.binarioEffettivo != nil) cell.binario.text = [NSString stringWithFormat:@"BINARIO %@",cell.fermata.binarioEffettivo];
    
    return cell;
}



-(void) deleteSubviews:(UIView*) view {
    
    for (UIView *sub in view.subviews)
    {
        [sub removeFromSuperview];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"%@",self.treno.fermate[indexPath.row]);
    [self performSegueWithIdentifier:@"dettaglioStazione" sender:self.treno.fermate[indexPath.row]];
  
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier  isEqual: @"dettaglioStazione"]) {
        DettaglioStazioneViewController *viewSegue = (DettaglioStazioneViewController*)[segue destinationViewController];
        Fermata *fermata = (Fermata*)sender;
        viewSegue.stazione = fermata.stazione;
    }
    
    
    
}


@end

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
    
    // bottone che mostra il numero del treno (con metodo per future implementazioni)
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:[self.treno stringaDescrizione]
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(flipView)];
    self.navigationItem.rightBarButtonItem = flipButton;
    
    // chiamo il metodo per impostare i dati sulla vista
    [self setData];
}

- (void)viewWillAppear:(BOOL)animated
{
    // tolgo qualsiasi selezione dalla tabella
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    

}

-(void) flipView {
    // future implementazioni possibili(?)
}

-(void) refresh {
    // carico il tutto subito con cacheLife = 0 (questo perchè l'utente ha richiesto il refresh)
    [self.treno caricaInfoComplete:0 completion:^{
        [self setData];
        [self.refreshControl endRefreshing];
    }];
}

// setta la schermata con i vari campi di testo
-(void) setData {
    
    if(self.attuale) {
    
    Stazione *rilevamento = [[Stazione alloc] init];
    rilevamento.nome = self.treno.stazioneUltimoRilevamento;

    if([rilevamento.nome isEqualToString:@"--"]) self.ultimoRilevamento.text = @"";
    else {
        if(self.treno.arrivato) self.ultimoRilevamento.text = @"ARRIVATO";
        else self.ultimoRilevamento.text = [NSString stringWithFormat:@"RILEVATO A %@",rilevamento.nome];

    }
    
        
    self.ritardo.text = [self.treno stringaRitardo];
    
    } else {
        self.ultimoRilevamento.text = @"";
        // siccome avrò impostata una data, visualizzo quella
        self.ritardo.text = [[DateUtils shared] showDateMedium:self.dataTreno];
    }
    
    self.orarioA.text = [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:self.treno.orarioArrivo]];
    self.orarioP.text = [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:self.treno.orarioPartenza]];
    
    self.stazioneP.text = self.treno.origine.nome;
    self.stazioneA.text = self.treno.destinazione.nome;
    
    // ricarico la tabella
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
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
    
    // disegno il progress view (pallini e linee del tragitto)
    JourneyProgressView *timeline = [[JourneyProgressView alloc] initWithRow:(int)indexPath.row andMax:(int)[self.treno.fermate count]-1 andCurrentStatus:cell.fermata.raggiunta andFrame:cell.progressView.frame];
    [cell.progressView addSubview:timeline];

    
    cell.nomeFermata.text = cell.fermata.stazione.nome;
    cell.orarioProgrammato.text = [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:cell.fermata.orarioProgrammato]];
    cell.orarioEffettivo.text = [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:cell.fermata.orarioEffettivo]];
    cell.orarioEffettivo.textColor = cell.fermata.raggiunta == TRUE ? GREEN : DARKGREY;
    
    if(cell.fermata.binarioEffettivo) cell.binario.text = [NSString stringWithFormat:@"BINARIO %@",cell.fermata.binarioEffettivo];
    else cell.binario.text = [NSString stringWithFormat:@"BINARIO %@",cell.fermata.binarioProgrammato];
    
    return cell;
}



-(void) deleteSubviews:(UIView*) view {
    
    for (UIView *sub in view.subviews)
    {
        [sub removeFromSuperview];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Fermata *fermata = self.treno.fermate[indexPath.row];
    Stazione *selezionata = fermata.stazione;
    // se seleziono una fermata mostro il dettaglio della stazione
    [self performSegueWithIdentifier:@"dettaglioStazione" sender:selezionata];
  
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if([segue.identifier  isEqual: @"dettaglioStazione"]) {
        DettaglioStazioneViewController *viewSegue = (DettaglioStazioneViewController*)[segue destinationViewController];
        Stazione *stazione = (Stazione*)sender;
        viewSegue.stazione = stazione;
    }
    
    
    
}


@end

//
//  SearchStazioneViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "SearchStazioneViewController.h"




@implementation SearchStazioneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // su un secondo thread recupero le stazioni
    [[ThreadHelper shared] executeInBackground:@selector(elencoStazioni) of:self completion:^(BOOL success) {
        [self.tableView reloadData];
    }];
    
    
    //basandomi su questo, http://jslim.net/blog/2014/07/14/remove-the-1px-shadow-from-uisearchbar/ per rimuovere la riga da 1px bianco
    self.searchDisplayController.searchBar.layer.borderColor = COLOR_WITH_RGB(201, 201, 206).CGColor;
    self.searchDisplayController.searchBar.layer.borderWidth = 1;

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// salva l'elenco delle stazioni in un array
-(void) elencoStazioni {
    
    NSArray* results  = [[DBHelper sharedInstance] executeSQLStatement:@"SELECT * FROM stazioni"];
    NSMutableArray *stazioni = [[NSMutableArray alloc] init];
    
    for (NSDictionary* set in results) {
        Stazione *stazione = [[Stazione alloc] init];
        
        stazione.idStazione = [set objectForKey:@"id"];
        stazione.nome       = [set objectForKey:@"nome"];
        
        [stazioni addObject:stazione];
    }
    
    self.stazioni =  [NSArray arrayWithArray:stazioni];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}
// metodo che differenzia il numero di righe se si è in searchDisplayController o meno
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [self.risultatiRicerca count];
    else return [self.stazioni count];
}

// metodo che disegna le celle, fare attenzione che opera diversamente se si è in ricerca o semplice scrolling senza ricerca
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"cellStazione";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    Stazione *stazione = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        stazione = [self.risultatiRicerca objectAtIndex:indexPath.row];
    } else {
        stazione = [self.stazioni objectAtIndex:indexPath.row];
   
    }
    
    cell.textLabel.text = stazione.nome;
    
    return cell;
}

// se la stazione viene selezionata la mando al viewcontroller precedente e faccio il pop dell'attuale
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.searchDisplayController.active) {
        indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
        self.selezionata = [self.risultatiRicerca objectAtIndex:indexPath.row];
    } else {
        indexPath = [self.tableView indexPathForSelectedRow];
        self.selezionata = [self.stazioni objectAtIndex:indexPath.row];
       
    }
 
    if(self.settaDestinazione) [self.delegate impostaStazioneA:self.selezionata];
    else [self.delegate impostaStazioneP:self.selezionata];
    
    [self.navigationController popViewControllerAnimated:YES];
}

// metodo che ricerca una soluzione
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(nome CONTAINS[cd] %@)",searchText];
    self.risultatiRicerca = [self.stazioni filteredArrayUsingPredicate:resultPredicate];
}

// metodo che chiama il precedente e aggiorna la tabella ogni volta che si inserisce un carattere per la ricerca
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

@end

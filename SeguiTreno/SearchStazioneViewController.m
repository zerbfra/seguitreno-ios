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

    
    
    self.stazioni = [[[Stazione alloc] init] elencoStazioni];
    
    //basandomi su questo, http://jslim.net/blog/2014/07/14/remove-the-1px-shadow-from-uisearchbar/ per rimuovere la riga da 1px bianco
    self.searchDisplayController.searchBar.layer.borderColor = COLOR_WITH_RGB(201, 201, 206).CGColor;
    self.searchDisplayController.searchBar.layer.borderWidth = 1;

    
    
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
    if (tableView == self.searchDisplayController.searchResultsTableView)
        return [self.risultatiRicerca count];
    else return [self.stazioni count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"cellStazione";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    Stazione *stazione = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        stazione = [self.risultatiRicerca objectAtIndex:indexPath.row];
    } else {
        stazione = [self.stazioni objectAtIndex:indexPath.row];
   
    }
    
    cell.textLabel.text = stazione.nome;
    
    return cell;
}

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


- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"(nome CONTAINS[cd] %@)",searchText];
    self.risultatiRicerca = [self.stazioni filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

@end

//
//  ScioperiViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "ScioperiViewController.h"
//#import "ScioperoTableViewCell.h"

@interface ScioperiViewController ()

@end

@implementation ScioperiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // status bar bianca
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    
    self.scioperi = [[NSMutableArray alloc] init];
    self.notizie = [[NSMutableArray alloc] init];

    [self requestInfo:YES completion:^{
        [self.tableView reloadData];
    }];
    
    
}

// richiedo informazioni al server, sia per scioperi che news (due chiamate diverse)
-(void) requestInfo:(BOOL)update completion:(void (^)(void))completionBlock {
    
    NSNumber* up = [NSNumber numberWithBool:update];
    
    // creo un gruppo di dispatch
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [[APIClient sharedClient] requestWithPath:@"scioperi" andParams:@{@"update":up} completion:^(NSDictionary *response) {
        
        for (NSDictionary *scioperoDict in response) {
            
            Notizia *sciopero = [[Notizia alloc] init];
            
            sciopero.titolo = [scioperoDict objectForKey:@"titolo"];
            sciopero.data = [scioperoDict objectForKey:@"data"];
            sciopero.testo = [self formattaTesto:[scioperoDict objectForKey:@"testo"]];
            
            [self.scioperi addObject:sciopero];
            
        }
        
        dispatch_group_leave(group);
        
        
        
    }];
    
    dispatch_group_enter(group);
    [[APIClient sharedClient] requestWithPath:@"news" andParams:@{@"update":up} completion:^(NSDictionary *response) {
        
        for (NSDictionary *newsDict in response) {
            
            Notizia *news = [[Notizia alloc] init];
            
            news.titolo = [newsDict objectForKey:@"titolo"];
            
            news.primopiano = [[newsDict objectForKey:@"primoPiano"] boolValue];
            news.data = [newsDict objectForKey:@"data"];
            news.testo = [newsDict objectForKey:@"testo"];
            
            [self.notizie addObject:news];
            
        }

        
        
        dispatch_group_leave(group);
        
        
    }];
    
    
    // quando finito eseguo il completionBlock
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{

        NSLog(@"Finito le richieste al server");
        // mando l'array
        completionBlock();
    });
    
}


-(NSString*) formattaTesto:(NSString*) stringa {
    NSString *clean = stringa.lowercaseString;
    
    // pulisco accenti trenitalia
    clean = [clean stringByReplacingOccurrencesOfString:@"`" withString:@"'"];
    
    return clean;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 88.0f;
    
    
}*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0) return [self.notizie count];
    else return [self.scioperi count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) return @"News e scioperi effettivi";
    else return @"Scioperi proclamati";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Notizia *cell;
    NSString *misura;
    
    if(indexPath.section == 0)  {
        cell = [self.notizie objectAtIndex:indexPath.row];
        misura = cell.testo;
    }
    else {
        cell = [self.scioperi objectAtIndex:indexPath.row];
        misura = cell.titolo;
    }
        
        UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:17.0];
        CGSize constraintSize = CGSizeMake(self.view.frame.size.width, 400.0f);
        
        CGRect textRect = [misura boundingRectWithSize:constraintSize
                                                 options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              attributes:@{NSFontAttributeName:cellFont}
                                                 context:nil];
        
        return textRect.size.height + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    if(indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notiziaCell" forIndexPath:indexPath];
        Notizia *newsCell = [self.notizie objectAtIndex:indexPath.row];
        cell.textLabel.text = newsCell.titolo;
        cell.detailTextLabel.text = newsCell.testo;
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        if([newsCell.testo containsString:@"sciopero"]) {
            cell.detailTextLabel.textColor = RED;
            cell.textLabel.textColor = RED;
        }

        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notiziaCell" forIndexPath:indexPath];
        Notizia *scioperoCell = [self.scioperi objectAtIndex:indexPath.row];
        cell.textLabel.text = scioperoCell.titolo;
        cell.detailTextLabel.text = scioperoCell.testo;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        
        return cell;
    }
    
    
 
}

@end

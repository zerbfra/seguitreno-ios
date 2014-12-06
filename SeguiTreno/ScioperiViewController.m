//
//  ScioperiViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "ScioperiViewController.h"
#import "ScioperoTableViewCell.h"

@interface ScioperiViewController ()

@end

@implementation ScioperiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // status bar bianca
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    
    self.scioperi = [[NSMutableArray alloc] init];

    
    [[APIClient sharedClient] requestWithPath:@"scioperi" andParams:@{@"numero":@"0"} completion:^(NSArray *response) {
        //NSLog(@"Response: %@", response);
        
        
        for (NSDictionary *scioperoDict in response) {
            
            Notizia *sciopero = [[Notizia alloc] init];
            

            
            
            sciopero.titolo = [scioperoDict objectForKey:@"titolo"];
            sciopero.titolo = [sciopero.titolo stringByReplacingOccurrencesOfString:@" - " withString:@"\n"];

            
            sciopero.data = [scioperoDict objectForKey:@"data"];
            sciopero.testo = [self formattaTesto:[scioperoDict objectForKey:@"testo"]];
            
            [self.scioperi addObject:sciopero];
            
        }
        
        [self.tableView reloadData];
        
        
        
    }];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.scioperi count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScioperoTableViewCell *cell = (ScioperoTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"scioperoCell" forIndexPath:indexPath];
    
    cell.sciopero = [self.scioperi objectAtIndex:indexPath.row];
    [cell disegna];
    // Configure the cell...
    
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

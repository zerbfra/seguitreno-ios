//
//  ImpostazioniViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 09/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "ImpostazioniViewController.h"
#import "DropboxClient.h"

@interface ImpostazioniViewController ()

@end

@implementation ImpostazioniViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // status bar bianca
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    NSString *versione = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.cellVersione.detailTextLabel.text = versione;
    
    [self updateDropboxLabel];
    
    // inizializzo gli spinner
    self.spinnerExport = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinnerImport = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinnerExport.frame = CGRectMake(0, 0, 24, 24);
    self.spinnerImport.frame = CGRectMake(0, 0, 24, 24);
    self.cellExport.accessoryView = self.spinnerExport;
    self.cellImport.accessoryView = self.spinnerImport;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
            [self manageDropbox];
            break;
        case 2:
            if(indexPath.row == 0) {
                [self.spinnerExport startAnimating];
                //esporta su dropbox (upload)
                [[DropboxClient shared] startTransfer:@"data.stdb" isItADownlaod:NO andReplace:YES completion:^{
                    [self.spinnerExport stopAnimating];
                }];
                
            }
            else  {
                [self.spinnerImport startAnimating];
                // importa da dropbox (download)
                [[DropboxClient shared] startTransfer:@"data.stdb" isItADownlaod:YES andReplace:YES completion:^{
                    [self.spinnerImport stopAnimating];
                }];
            }
            break;
        case 3:
            if(indexPath.row == 0) [self sendFeedback];
            else [self twitterButton];
            break;
        case 4:
            if(indexPath.row == 1) [self leaveReview];
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void) manageDropbox {
    DBAccountManager *manager = [[DropboxClient shared] manageDropbox:self];
    
    // in ogni caso aggiorno (il manager non notifica in caso di unlink)
    [self updateView];
    
    // se arriva notifica dal manager qualcosa è cambiato, aggiorno nuovamente!
    [manager addObserver:self block:^(DBAccount *account) {
        NSLog(@"DBAccountmanager changed");
        [self updateView];
    }];
    
    
    
}

-(void) updateView {
    [self updateDropboxLabel];
    [UIView transitionWithView:self.tableView
                      duration:0.1f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^(void) {
                        [self.tableView reloadData];
                    } completion:NULL];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if([[DropboxClient shared] isDropboxLinked]) {
        
        switch (section) {
            case 2:
                return 2;
                break;
            case 3:
                return 2;
                break;
            default:
                return 1;
                break;
        }
        
    } else {
        
        switch (section) {
            case 2:
                if([[DropboxClient shared] isDropboxLinked])  return 2;
                else return 0;
                break;
            case 3:
                return 2;
                break;
            case 4:
                return 2;
                break;
            default:
                return 1;
                break;
        }
    }
    
    
    
}

-(void) updateDropboxLabel {
    
    if(![[DropboxClient shared] isDropboxLinked]) {
        self.cellDropbox.textLabel.text = @"Collega a Dropbox";
    } else {
        self.cellDropbox.textLabel.text = @"Scollega Dropbox";
    }
}

/* Apre app store per la recensione */
- (void)leaveReview {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id790926556"]];
}

/* Avvia app di twitter/apre sito web */
- (void)twitterButton {
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?id=88692560"]];
    }
    else [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/zerbfra"]];
}

/* Metodo per l'invio di mail di feedback */
- (void)sendFeedback {
    // Email Subject
    NSString *emailTitle = @"SeguiTreno Feedback";
    
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"francesco@zerbinatifrancesco.it"];
    
    //NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey: deviceTokenKey];
    //NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    [mc setSubject:emailTitle];
    [mc setToRecipients:toRecipents];
    
    mc.mailComposeDelegate = self;
    // Present mail view controller on screen
    
    if ([MFMailComposeViewController canSendMail]) {
        [self presentViewController:mc animated:YES completion:NULL];
    } else NSLog(@"No account mail");
    
    
    
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



@end

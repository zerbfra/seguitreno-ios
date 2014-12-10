//
//  ImpostazioniViewController.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 09/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Dropbox/Dropbox.h>

@interface ImpostazioniViewController : UITableViewController <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *cellVersione;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDropbox;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellExport;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellImport;

@property (strong,nonatomic) UIActivityIndicatorView *spinnerExport;
@property (strong,nonatomic) UIActivityIndicatorView *spinnerImport;


@end

//
//  DettaglioTrenoViewController.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 17/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DettaglioTrenoViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) Treno *treno;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *orarioP;
@property (weak, nonatomic) IBOutlet UILabel *orarioA;

@property (weak, nonatomic) IBOutlet UILabel *stazioneP;
@property (weak, nonatomic) IBOutlet UILabel *stazioneA;



@end

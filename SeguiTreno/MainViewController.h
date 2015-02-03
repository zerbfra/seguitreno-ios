//
//  MainView.h
//  TrenoSmart
//
//  Created by Francesco Zerbinati on 04/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZDatepicker.h"
#import "SalvatoTableViewCell.h"

@interface MainViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet FZDatepicker *datepicker;
@property (weak, nonatomic) IBOutlet UITableView *treniTable;
@property (strong,nonatomic) UIRefreshControl *refreshControl;


// contiene i viaggi della data attuale
@property (strong,nonatomic) NSMutableArray *viaggi;



@end

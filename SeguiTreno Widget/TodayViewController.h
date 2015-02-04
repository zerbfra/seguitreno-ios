//
//  TodayViewController.h
//  SeguiTreno Widget
//
//  Created by Francesco Zerbinati on 04/02/15.
//  Copyright (c) 2015 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *wdgTable;

//@property (strong,nonatomic) NSArray* dbTreni;
@property (strong,nonatomic) NSMutableArray* treniOggi;


@end

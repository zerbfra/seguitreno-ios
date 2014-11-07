//
//  MainView.h
//  TrenoSmart
//
//  Created by Francesco Zerbinati on 04/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FZDatepicker.h"

@interface MainView : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet FZDatepicker *datepicker;
@property (weak, nonatomic) IBOutlet UITableView *treniTable;

@property NSString *text;

@end

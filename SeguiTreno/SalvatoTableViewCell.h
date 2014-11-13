//
//  SalvatoTableViewCell.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 13/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SalvatoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *partenzaL;
@property (weak, nonatomic) IBOutlet UILabel *arrivoL;
@property (weak, nonatomic) IBOutlet UILabel *trenoL;
@property (weak, nonatomic) IBOutlet UILabel *countdownL;
@property (weak, nonatomic) IBOutlet UILabel *orarioPL;
@property (weak, nonatomic) IBOutlet UILabel *orarioAL;
@property (weak, nonatomic) IBOutlet UILabel *ritardoL;

@property Treno* treno;

@end

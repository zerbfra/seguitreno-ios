//
//  TrenoStazioneTableViewCell.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 28/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrenoStazioneTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *status;
@property (weak, nonatomic) IBOutlet UILabel *info;
@property (weak, nonatomic) IBOutlet UILabel *treno;

-(void) setRitardo:(NSInteger) ritardo;

@end

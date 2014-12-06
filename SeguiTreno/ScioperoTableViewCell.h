//
//  ScioperoTableViewCell.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notizia.h"

@interface ScioperoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titolo;
@property (weak, nonatomic) IBOutlet UILabel *descrizione;

@property (strong,nonatomic) Notizia *sciopero;

-(void) disegna;

@end

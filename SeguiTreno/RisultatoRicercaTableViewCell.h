//
//  RisultatoRicercaTableViewCell.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 01/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RisultatoRicercaTableViewCell : UITableViewCell

@property Viaggio *soluzione;

@property (weak, nonatomic) IBOutlet UILabel *treno;
@property (weak, nonatomic) IBOutlet UILabel *orarioP;
@property (weak, nonatomic) IBOutlet UILabel *orarioA;
@property (weak, nonatomic) IBOutlet UILabel *partenza;
@property (weak, nonatomic) IBOutlet UILabel *arrivo;

-(void) disegna;

@end

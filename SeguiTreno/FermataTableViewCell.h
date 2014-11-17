//
//  FermataTableViewCell.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 17/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FermataTableViewCell : UITableViewCell

@property (strong,nonatomic) Fermata *fermata;


@property (weak, nonatomic) IBOutlet UIView *progressView;

@property (weak, nonatomic) IBOutlet UILabel *nomeFermata;

@property (weak, nonatomic) IBOutlet UILabel *orarioProgrammato;
@property (weak, nonatomic) IBOutlet UILabel *orarioEffettivo;

@property (weak, nonatomic) IBOutlet UILabel *binario;

@end

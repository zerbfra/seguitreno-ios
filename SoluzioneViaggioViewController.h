//
//  SoluzioneViaggioViewController.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 07/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SoluzioneViaggioDelegate <NSObject>
- (void) impostaTreno:(Treno *) trenoSelezionato;
@end

@interface SoluzioneViaggioViewController : UITableViewController

@property (strong,nonatomic) NSMutableArray *soluzioniPossibili;

@property (strong,nonatomic) Treno *trenoQuery;

@property (weak, nonatomic) id <SoluzioneViaggioDelegate> delegate;

@end

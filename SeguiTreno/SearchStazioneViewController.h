//
//  SearchStazioneViewController.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 06/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SearchStazioneDelegate <NSObject>
- (void) impostaStazioneP:(Stazione *) stazioneP;
- (void) impostaStazioneA:(Stazione *)stazioneA;
@end

@interface SearchStazioneViewController : UITableViewController

@property (nonatomic,strong) NSArray *stazioni;
@property (nonatomic,strong) NSArray *risultatiRicerca;

@property (nonatomic,strong) Stazione   *selezionata;
@property (nonatomic) BOOL settaDestinazione;


@property (weak, nonatomic) id <SearchStazioneDelegate> delegate;

@end




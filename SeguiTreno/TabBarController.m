//
//  TabBarController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 08/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "TabBarController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:111.0/255.0 green:194.0/255.0 blue:59.0/255.0 alpha:1.0]];
    
    // sistema gli oggetti con relative immagini per la tab bar
    [[self.tabBar.items objectAtIndex:0] setFinishedSelectedImage:[UIImage imageNamed:@"calendarioTab"] withFinishedUnselectedImage:[UIImage imageNamed:@"calendarioTab"]];
    [[self.tabBar.items objectAtIndex:1] setFinishedSelectedImage:[UIImage imageNamed:@"trenoTab"] withFinishedUnselectedImage:[UIImage imageNamed:@"trenoTab"]];
    [[self.tabBar.items objectAtIndex:2] setFinishedSelectedImage:[UIImage imageNamed:@"scioperoTab"] withFinishedUnselectedImage:[UIImage imageNamed:@"scioperoTab"]];
    [[self.tabBar.items objectAtIndex:3] setFinishedSelectedImage:[UIImage imageNamed:@"stazioniTab"] withFinishedUnselectedImage:[UIImage imageNamed:@"stazioniTab"]];
    [[self.tabBar.items objectAtIndex:4] setFinishedSelectedImage:[UIImage imageNamed:@"settingsTab"] withFinishedUnselectedImage:[UIImage imageNamed:@"settingsTab"]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

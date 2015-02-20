//
//  TodayViewController.m
//  SeguiTreno Widget
//
//  Created by Francesco Zerbinati on 04/02/15.
//  Copyright (c) 2015 Francesco Zerbinati. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // assegno delegate e datasource
    self.wdgTable.delegate = self;
    self.wdgTable.dataSource = self;
    
    // grafica
    self.wdgTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.wdgTable.frame.size.width, 1)];
    
    
    // dimensione a 0 di default
    //CGSize size = self.preferredContentSize;
    //size.height = 0.0f;
    //self.preferredContentSize = size;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // carico il database dei treni
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.it.zerbinatifrancesco.SeguiTreno"];
    NSArray* dbTreni = [sharedDefaults objectForKey:@"treniDBKey"];
    //NSLog(@"%@",dbTreni);
    
    self.treniOggi = [NSMutableArray array];
    
    // seleziono solo i treni di oggi
    [dbTreni enumerateObjectsUsingBlock:^(id treno, NSUInteger idx, BOOL *stop) {
        NSTimeInterval timestamp = [[treno objectForKey:@"data"] doubleValue];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
        if([self isToday:date]) [self.treniOggi addObject:treno];
    }];
    
    // ordino per orario (con il blocco!)
    self.treniOggi = [[self.treniOggi sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return [[a objectForKey:@"data"] compare:[b objectForKey:@"data"]];
    }] mutableCopy];
    
    [self.wdgTable reloadData];
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

// grafica per i margini
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // numero di sezioni: 1
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        // tante righe quanti sono i treni odierni, imposto la dimensione in base alle righe
        CGSize size = self.preferredContentSize;
        size.height = [self.treniOggi count] * 44.0f;
        self.preferredContentSize = size;
        return [self.treniOggi count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // altezza delle righe
    return 44;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *url = [NSURL URLWithString:@"seguitreno://"];
    [self.extensionContext openURL:url completionHandler:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"wdgCell";
    
    
  
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSTimeInterval timestamp = [[[self.treniOggi objectAtIndex:indexPath.row] objectForKey:@"data"] doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];


    cell.detailTextLabel.text = [self showHHmm:date];
    NSString *label = [NSString stringWithFormat:@"%@ %@",[[self.treniOggi objectAtIndex:indexPath.row] objectForKey:@"categoria"],[[self.treniOggi objectAtIndex:indexPath.row] objectForKey:@"numero"]];
    cell.textLabel.text = label;
    
    
    return cell;
}

#pragma mark date functions

-(NSString*) showHHmm:(NSDate*) date {
    
    if(date == nil) date = [NSDate date];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    
    NSString *dateString = [timeFormatter stringFromDate: date];
    
    return dateString;
}

- (BOOL)isToday:(NSDate*)date {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    
    components = [cal components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *otherDate = [cal dateFromComponents:components];
    
    if([today isEqualToDate:otherDate]) return YES;
    else return NO;
}

@end

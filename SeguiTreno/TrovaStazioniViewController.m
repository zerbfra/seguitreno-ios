//
//  TrovaStazioniViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 07/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "TrovaStazioniViewController.h"
#define MINIMUM_ZOOM_ARC 0.014 
#define ANNOTATION_REGION_PAD_FACTOR 1.3
#define MAX_DEGREES_ARC 360


@implementation TrovaStazioniViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // status bar bianca
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self localizza];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

// metodo che localizza l'utente tramite il GPS
-(void) localizza {
    [[LocationManager sharedInstance] startWithAuthType:LocationManageraAuthTypeWhenInUse
                                         filterDistance:kCLDistanceFilterNone
                                               accuracy:kCLLocationAccuracyThreeKilometers
                                        completionBlock:^(CLLocation *newLocation, Error error) {
                                            if (newLocation != nil) {
                                                NSLog(@"Ricevuta posizione: %f, %f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
                                                
                                                [[ThreadHelper shared] executeInBackground:@selector(elencoStazioniVicineA:) of:self withParam:newLocation completion:^(BOOL success) {
                                                    NSLog(@"Caricate stazioni vicine");
                                                    [self configuraMappa];
                                                    [self zoomMapViewToFitAnnotations:self.mapView animated:NO];
                                                    [self.tableView reloadData];
                                                    
                                                }];
                                                
                                            } else {
                                                NSLog(@"Found error");
                                            }
                                            [[LocationManager sharedInstance] stopUpdate];
                                        }];
}
// aggiunge i punti sulla mappa relativi alle stazioni vicine
-(void) configuraMappa {
    
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsPointsOfInterest = false;
    self.mapView.showsUserLocation = true;
    
    for (int i = 0; i < [self.stazioniVicine count]; i++) {
        
        Stazione *vicina = [self.stazioniVicine objectAtIndex:i];
        
        CLLocationDegrees lat =  vicina.lat;
        CLLocationDegrees lon = vicina.lon;
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat,lon);
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:coord];
        [annotation setTitle:vicina.nome];
        [self.mapView addAnnotation:annotation];
        
   
        
        [annotation setCoordinate:coord];
        [self.mapView addAnnotation:annotation];
        
        
    }
    
}

// sistema la vista per il pin
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // tutte tranne la user location
    if([annotation isKindOfClass: [MKUserLocation class]]) return nil;
    
    static NSString *SFAnnotationIdentifier = @"SFAnnotationIdentifier";
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:SFAnnotationIdentifier];
    if (!pinView)
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                        reuseIdentifier:SFAnnotationIdentifier];
        UIImage *flagImage = [UIImage imageNamed:@"logofs"];
        annotationView.image = flagImage;
        annotationView.canShowCallout = YES;
        return annotationView;
    }
    else
    {
        pinView.annotation = annotation;
    }
    return pinView;
}
// ritorna l'elenco delle stazioni vicine a un oggetto CLLOcation (scrive su self.stazionivicine)
-(void) elencoStazioniVicineA:(CLLocation *) currentLocation {
    
    NSArray* results  = [[DBHelper sharedInstance] executeSQLStatement:@"SELECT * FROM stazioni"];
    NSMutableArray *stazioni = [[NSMutableArray alloc] init];
    NSMutableArray *vicine = [[NSMutableArray alloc] init];
    
    for (NSDictionary* set in results) {
        Stazione *stazione = [[Stazione alloc] init];
        
        stazione.idStazione = [set objectForKey:@"id"];
        stazione.nome       = [set objectForKey:@"nome"];
        //[stazione formattaNome];
        stazione.lat       = [[set objectForKey:@"lat"] floatValue];
        stazione.lon       = [[set objectForKey:@"lon"] floatValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:stazione.lat longitude:stazione.lon];
        stazione.posizione = location;
        [stazione formattaNome];
        [stazioni addObject:stazione];
    }
    
    for (Stazione *temp in stazioni) {
        CLLocationDistance distance = [currentLocation distanceFromLocation:temp.posizione];
        //NSLog(@"%f",distance);
        //distanza minore di 10km
        if (distance < 10000) {
            temp.distanza = distance;
            [vicine addObject:temp];
            //NSLog(@"%@",temp.nome);
        }
    }
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"distanza" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sort];
    self.stazioniVicine = [vicine sortedArrayUsingDescriptors:sortDescriptors];

}


// sistema la mappa in modo che le annotazioni siano centrali
- (void)zoomMapViewToFitAnnotations:(MKMapView *)mapView animated:(BOOL)animated
{
    NSArray *annotations = mapView.annotations;
    NSInteger count = [mapView.annotations count];
    
    if ( count == 0) { return; } //bail if no annotations
    
    //convert NSArray of id <MKAnnotation> into an MKCoordinateRegion that can be used to set the map size
    //can't use NSArray with MKMapPoint because MKMapPoint is not an id
    MKMapPoint points[count]; //C array of MKMapPoint struct
    for( int i=0; i<count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MKAnnotation>)[annotations objectAtIndex:i] coordinate];
        points[i] = MKMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MKMapRect mapRect = [[MKPolygon polygonWithPoints:points count:count] boundingMapRect];
    //convert MKCoordinateRegion from MKMapRect
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //add padding so pins aren't scrunched on the edges
    region.span.latitudeDelta  *= ANNOTATION_REGION_PAD_FACTOR;
    region.span.longitudeDelta *= ANNOTATION_REGION_PAD_FACTOR;
    //but padding can't be bigger than the world
    if( region.span.latitudeDelta > MAX_DEGREES_ARC ) { region.span.latitudeDelta  = MAX_DEGREES_ARC; }
    if( region.span.longitudeDelta > MAX_DEGREES_ARC ){ region.span.longitudeDelta = MAX_DEGREES_ARC; }
    
    //and don't zoom in stupid-close on small samples
    if( region.span.latitudeDelta  < MINIMUM_ZOOM_ARC ) { region.span.latitudeDelta  = MINIMUM_ZOOM_ARC; }
    if( region.span.longitudeDelta < MINIMUM_ZOOM_ARC ) { region.span.longitudeDelta = MINIMUM_ZOOM_ARC; }
    //and if there is a sample of 1 we want the max zoom-in instead of max zoom-out
    if( count == 1 )
    {
        region.span.latitudeDelta = MINIMUM_ZOOM_ARC;
        region.span.longitudeDelta = MINIMUM_ZOOM_ARC;
    }
    [mapView setRegion:region animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections: pari al numero di viaggi di una giornata (i treni sono raggruppati in viaggi)
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.stazioniVicine count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"cellStazione";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    Stazione *stazione = [self.stazioniVicine objectAtIndex:indexPath.row];
    cell.textLabel.text = stazione.nome;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    Stazione *selezionata = self.stazioniVicine[indexPath.row];
    [self performSegueWithIdentifier:@"dettaglioStazione" sender:selezionata];
    
    
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier  isEqual: @"dettaglioStazione"]) {
        DettaglioStazioneViewController *viewSegue = (DettaglioStazioneViewController*)[segue destinationViewController];
        Stazione *dettaglio = (Stazione*)sender;
        viewSegue.stazione = dettaglio;
    }
    
    
    
}

@end

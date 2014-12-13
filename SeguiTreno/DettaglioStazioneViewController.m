//
//  DettaglioStazioneViewController.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 27/11/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "DettaglioStazioneViewController.h"
#import "DettaglioTrenoViewController.h"
#import "TrenoStazioneTableViewCell.h"

#define MINIMUM_ZOOM_ARC 0.014 //approximately 1 miles (1 degree of arc ~= 69 miles)
#define ANNOTATION_REGION_PAD_FACTOR 1.15
#define MAX_DEGREES_ARC 360

@interface DettaglioStazioneViewController ()

@end

@implementation DettaglioStazioneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    //[self configuraMappa];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    
    //self.treniArrivo = [NSMutableArray array];
    //self.treniPartenza = [NSMutableArray array];
    
    self.navigationItem.title = self.stazione.nome;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator startAnimating];
    
    //[notification displayNotificationWithMessage:@"Caricamento..." completion:nil];
    
    [self.stazione caricaTreniStazione:^{
        //[notification dismissNotification];
        [self.tableView reloadData];
        
        //eseguo query al db per la mappa in background
        [[ThreadHelper shared] executeInBackground:@selector(configuraMappa) of:self completion:^(BOOL success) {
            [self zoomMapViewToFitAnnotations:self.mapView animated:YES];
        }];
        
        
        [activityIndicator stopAnimating];
    }];
    
    //[self.tableView reloadData];
    //[self caricaTreni];
    
}

-(void) configuraMappa {
    
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    
    NSString *query = [NSString stringWithFormat:@"SELECT lat,lon FROM stazioni WHERE id='%@'",self.stazione.idStazione];
    NSArray *results = [[DBHelper sharedInstance] executeSQLStatement:query];
    // non tutte le stazioni sono presenti nel db (limitazione data da trenitalia)
    if([results count] > 0) {
        NSDictionary *result= [results objectAtIndex:0];
    
        CLLocationDegrees lat =  [[result objectForKey:@"lat"] doubleValue];
        CLLocationDegrees lon = [[result objectForKey:@"lon"] doubleValue];
    
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat,lon);
    
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:coord];
        [annotation setTitle:self.stazione.nome];
        [self.mapView addAnnotation:annotation];
    }
    
}

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
        // You may need to resize the image here.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//size the mapView region to fit its annotations
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


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   
    switch (section) {
        case 0:
            if([self.stazione.treniPartenza count] > 0)  return @"PARTENZE PER:";
            else return nil;
            break;
        case 1:
            if([self.stazione.treniArrivo count] > 0) return @"ARRIVI DA:";
            else return nil;
            break;
            
        default:
            return  nil;
            break;
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(section == 0) {
        if([self.stazione.treniPartenza count] > 0) return [self.stazione.treniPartenza count];
        else return 0;
    }
    else {
        if([self.stazione.treniArrivo count] > 0) return [self.stazione.treniArrivo count];
        else return 0;
    }
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0)
    [self performSegueWithIdentifier:@"dettaglioTreno" sender:[self.treniPartenza objectAtIndex:indexPath.row]];
    else [self performSegueWithIdentifier:@"dettaglioTreno" sender:[self.treniArrivo objectAtIndex:indexPath.row]];

    
}
 */


 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     TrenoStazioneTableViewCell *cell = (TrenoStazioneTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"trainCell" forIndexPath:indexPath];
 


     
     if(indexPath.section == 0) {
         //partenze
         if([self.stazione.treniPartenza count] > 0) {
             Treno *partenza = [self.stazione.treniPartenza objectAtIndex:indexPath.row];
             cell.treno.text = [partenza stringaDescrizione];
             cell.info.text = partenza.destinazione.nome;
             
             if(partenza.ritardo > 0) {
                 NSString *stringaRitardo = [NSString stringWithFormat:@"Ritardo %ld min",partenza.ritardo];
                 cell.orario.text = [NSString stringWithFormat:@"%@ - %@",[[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:partenza.orarioPartenza]],stringaRitardo];
             } else cell.orario.text = [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:partenza.orarioPartenza]];
             
             [cell setRitardo:partenza.ritardo];
         } else {
             cell.treno.text = @"";
             cell.info.text = @"Nessun treno in partenza";
         }
         
     } else {
         //arrivi
         if([self.stazione.treniArrivo count] > 0) {
             Treno *arrivo = [self.stazione.treniArrivo objectAtIndex:indexPath.row];
             cell.treno.text = [arrivo stringaDescrizione];
             cell.info.text = arrivo.origine.nome;
             
             if(arrivo.ritardo > 0) {
                 NSString *stringaRitardo = [NSString stringWithFormat:@"Ritardo %ld min",arrivo.ritardo];
                 cell.orario.text = [NSString stringWithFormat:@"%@ - %@",[[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:arrivo.orarioArrivo]],stringaRitardo];
             } else cell.orario.text = [[DateUtils shared] showHHmm:[[DateUtils shared] dateFrom:arrivo.orarioArrivo]];
             
             [cell setRitardo:arrivo.ritardo];
         } else {
             cell.treno.text = @"Nessun treno in arrivo";
             cell.info.text = @"";
         }
         
     }
     
     

     return cell;
 }

/*
-(void) caricaTreni {
    
    NSLog(@"%@",self.stazione.idStazione);
    
    // creo un gruppo di dispatch
    dispatch_group_t group = dispatch_group_create();

        
        dispatch_group_enter(group);
        
        [[APIClient sharedClient] requestWithPath:@"treniArrivo" andParams:@{@"stazione":self.stazione.idStazione} completion:^(NSArray *response) {
            //NSLog(@"%@",response);
            
            for(NSDictionary *trenoDict in response) {
                // controllo che non sia stato restituito un null (può succedere in casi eccezzionali)
                Treno *treno = [[Treno alloc] init];
                treno.categoria = [trenoDict objectForKey:@"categoria"];
                treno.numero = [trenoDict objectForKey:@"numero"];
                Stazione *origine = [[Stazione alloc] init];
                origine.idStazione = [trenoDict objectForKey:@"idOrigine"];
                origine.nome = [trenoDict objectForKey:@"origine"];
                
                [origine formattaNome];
                
                treno.origine = origine;
                treno.orarioArrivo = [[trenoDict objectForKey:@"orarioArrivo"] intValue];
                treno.ritardo = [[trenoDict objectForKey:@"ritardo"] intValue];
                [self.treniArrivo addObject:treno];
                
            }
            
            
            
            dispatch_group_leave(group);
            
        }];
        
        dispatch_group_enter(group);
        
        [[APIClient sharedClient] requestWithPath:@"treniPartenza" andParams:@{@"stazione":self.stazione.idStazione} completion:^(NSArray *response) {
            //NSLog(@"%@",response);
            
            for(NSDictionary *trenoDict in response) {
                // controllo che non sia stato restituito un null (può succedere in casi eccezzionali)
                Treno *treno = [[Treno alloc] init];
                treno.categoria = [trenoDict objectForKey:@"categoria"];
                treno.numero = [trenoDict objectForKey:@"numero"];
                Stazione *destinazione = [[Stazione alloc] init];
                destinazione.nome = [trenoDict objectForKey:@"destinazione"];
                
                Stazione *origine = [[Stazione alloc] init];
                origine.idStazione = [trenoDict objectForKey:@"idOrigine"];
                
                [destinazione formattaNome];
                
                treno.origine = origine;
                treno.destinazione = destinazione;
                
                treno.ritardo = [[trenoDict objectForKey:@"ritardo"] intValue];
                treno.orarioPartenza = [[trenoDict objectForKey:@"orarioPartenza"] intValue];
                [self.treniPartenza addObject:treno];
                
            }
            
            dispatch_group_leave(group);
            
        }];
        
    
    
    
    // Here we wait for all the requests to finish
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Do whatever you need to do when all requests are finished
        NSLog(@"Finito le richieste al server");
        [self.tableView reloadData];
 
    });
    
}
*/


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"dettaglioTreno"]) {
        

        Treno * treno = (Treno*) sender;
        
        DettaglioTrenoViewController *destination = (DettaglioTrenoViewController*) [segue destinationViewController];
        destination.treno = treno;
        
        // dico al dettaglio se è il treno della giornata attuale o meno
        destination.attuale = YES;
        
        destination.dataTreno = [NSDate date];
        
        
    }
    

}
*/

@end

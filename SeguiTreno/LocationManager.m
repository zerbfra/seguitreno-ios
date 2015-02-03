//
//  LocationManager.m
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 07/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import "LocationManager.h"

@implementation LocationManager

+ (LocationManager *)sharedInstance {
    static dispatch_once_t once;
    static LocationManager * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
        
    });
    return sharedInstance;
}

- (void)startWithAuthType:(LocationManageraAuthType)authType
        filterDistance:(CLLocationDistance)distanceFilter
              accuracy:(CLLocationAccuracy)accuracy
       completionBlock:(void(^)(CLLocation *newLocation, Error error))completionBlock {
    
        self.completionBlock = completionBlock;

        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = distanceFilter;
        self.locationManager.desiredAccuracy = accuracy;
        [self startUpdatingLocation:authType];
}

// prima di tutto richiede l'autorizzazione ad usare la posizione all'utente e poi inizia a controllare la posizione sul locationamanger
- (void)startUpdatingLocation:(LocationManageraAuthType)authType {
    switch (authType) {
        case LocationManageraAuthTypeWhenInUse: {
            // Check per iOS 8.
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            break;
        }
        case LocationManageraAuthTypeAlways: {
            // Check per iOS 8.
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestAlwaysAuthorization];
            }
            break;
        }
    }
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdate {
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.completionBlock([locations lastObject], 0);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    NSLog(@"Impostazioni geolocalizzazione cambiate");
    
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            [self.locationManager startUpdatingLocation];
            break;
        }
        case kCLAuthorizationStatusRestricted:
            self.completionBlock(nil, ErrorUserRestricted);
            break;
            
        default: {
            //Do nothing
            break;
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    switch (error.code) {
        case kCLErrorDenied:{
            self.completionBlock(nil, ErrorUserDenied);
            break;
        }
        default:{
            //Do nothing.
            break;
        }
    }
}


@end

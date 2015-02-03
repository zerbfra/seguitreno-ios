//
//  LocationManager.h
//  SeguiTreno
//
//  Created by Francesco Zerbinati on 07/12/14.
//  Copyright (c) 2014 Francesco Zerbinati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;

typedef NS_ENUM(NSUInteger, Error) {
    ErrorUserDenied = 1,
    ErrorUserRestricted
};


typedef NS_ENUM(NSUInteger, LocationManageraAuthType) {
    LocationManageraAuthTypeWhenInUse,
    LocationManageraAuthTypeAlways
};

// singleton
+ (LocationManager *)sharedInstance;

// avvia la localizzaione
- (void) startWithAuthType:(LocationManageraAuthType)authType filterDistance:(CLLocationDistance)distanceFilter accuracy:(CLLocationAccuracy)accuracy
       completionBlock:(void(^)(CLLocation *newLocation, Error error))completionBlock;

// ferma la localizzazione
- (void) stopUpdate;

@property (nonatomic, copy) void (^completionBlock)(CLLocation *newLocation, Error error);

@end

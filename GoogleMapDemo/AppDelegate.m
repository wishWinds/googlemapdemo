//
//  AppDelegate.m
//  GoogleMapDemo
//
//  Created by dev on 2020/11/9.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import <JZLocationConverter/JZLocationConverter.h>
#import "GoogleMapViewController.h"

@interface AppDelegate () <CLLocationManagerDelegate>
@property(nonatomic, assign) NSInteger index;
@property(nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        NSLog(@"startup with silent");
    }

    [self registerLocalNotifaction];

    [GMSServices provideAPIKey:@"AIzaSyB4uPX7Lc5PxA1atuSsp1ebXekx7-mt0xA"];

    [self setupLocationManager];

    [self clearPrevilousRegions];

    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(-33.711431, 151.1080853);
    [self monitorRegionAt:location];

    return YES;
}

// MARK: Helper

- (void)setupLocationManager {
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 5.0f;


    self.locationManager.pausesLocationUpdatesAutomatically = false; // let system stop update location if needed
    self.locationManager.allowsBackgroundLocationUpdates = true; // disallow background mode, we does not need for NOW!

    [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
}

- (void)clearPrevilousRegions {
    [self.locationManager.monitoredRegions enumerateObjectsUsingBlock:^(__kindof CLRegion *_Nonnull obj, BOOL *_Nonnull stop) {
        [self.locationManager stopMonitoringForRegion:obj];
    }];
}

- (void)monitorRegionAt:(CLLocationCoordinate2D)location {
    CLLocationDistance radius = 200;
    if (radius > self.locationManager.maximumRegionMonitoringDistance) {
        radius = self.locationManager.maximumRegionMonitoringDistance;
    }
    NSString *identifier = [NSString stringWithFormat:@"%f , %f", location.latitude, location.longitude];
    CLRegion *region = [[CLCircularRegion alloc] initWithCenter:location
                                                         radius:radius
                                                     identifier:identifier];
    [self.locationManager startMonitoringForRegion:region];
}


- (void)registerLocalNotifaction {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError *_Nullable error) {
    }];
}

- (void)registerNotificationWithMsg:(NSString *)msg {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"Notification"
                                                          arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:msg
                                                         arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    NSInteger alerTime = 1;
    UNTimeIntervalNotificationTrigger *trigger =
            [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alerTime
                                                               repeats:NO];
    UNNotificationRequest *request =
            [UNNotificationRequest requestWithIdentifier:@"noti"
                                                 content:content
                                                 trigger:trigger];

    [center addNotificationRequest:request withCompletionHandler:^(NSError *error) {
    }];
}

- (GoogleMapViewController *)mapVC {
    return (GoogleMapViewController *) self.window.rootViewController;
}

// MARK: location manager delegate

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    [self registerNotificationWithMsg:@"Check In"];
    [self mapVC].checkState = 1;
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    [self registerNotificationWithMsg:@"Check Out"];
    [self mapVC].checkState = 0;
}


@end

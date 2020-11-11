//
//  GoogleMapViewController.m
//  GoogleMapDemo
//
//  Created by shupeng on 2020/11/9.
//

#import "GoogleMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface GoogleMapViewController () <GMSMapViewDelegate>
//@interface GoogleMapViewController ()
@property (nonatomic, strong) GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *controlPannel;
@property (nonatomic, assign) BOOL firstLocationUpdate;
@property (weak, nonatomic) IBOutlet UIView *stateView;
@end

@implementation GoogleMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createMapView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createMapView {
    if (self.mapView != nil) {
        return;
    }

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:12];

    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    self.mapView.delegate = self;
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;

    [self.view insertSubview:self.mapView belowSubview:self.controlPannel];

    [self.mapView addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
    
    [self createCircle];
}

- (void)destroyMapView {
    [self.mapView removeFromSuperview];
    self.mapView = nil;
    self.firstLocationUpdate = false;
}

- (void)createCircle {
    GMSCircle *circle = [[GMSCircle alloc] init];
    circle.position = CLLocationCoordinate2DMake(30.507544369000442,114.4133872013031);
    circle.radius = 300;
    circle.strokeWidth = 0;
    circle.fillColor = [UIColor colorWithDisplayP3Red:0.5 green:0.67 blue:1 alpha:0.66];
    
    circle.map = self.mapView;
}

- (void)didEnterBackground:(NSNotification *)noti {
    [self destroyMapView];
}

- (void)willBecomeActive:(NSNotification *)noti {
    [self createMapView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (!_firstLocationUpdate) {
    // If the first location update has not yet been received, then jump to that
    // location.
    _firstLocationUpdate = YES;
    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
    _mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                     zoom:15];
  }
}
- (IBAction)checkInButtonPressed:(id)sender {
    [self checkIn];
}

- (IBAction)checkoutButtonPressed:(id)sender {
    [self checkOut];
}

- (void)checkIn {
    self.checkState = 1;
}

- (void)checkOut {
    self.checkState = 0;
}

- (void)setCheckState:(int)checkState {
    _checkState = checkState;
    
    if (checkState == 1) {
        self.stateView.backgroundColor = [UIColor greenColor];
    } else {
        self.stateView.backgroundColor = [UIColor redColor];
    }
}
@end

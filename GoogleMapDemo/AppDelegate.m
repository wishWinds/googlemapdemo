//
//  AppDelegate.m
//  GoogleMapDemo
//
//  Created by shupeng on 2020/11/9.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>
#import <JZLocationConverter/JZLocationConverter.h>
#import "GoogleMapViewController.h"

@interface AppDelegate () <CLLocationManagerDelegate>
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"启动 %@", launchOptions);
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        NSLog(@"区域监测唤醒");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self registerNotificationWithMsg:launchOptions.description];
            [self alertWithMsg:launchOptions.description];
        });
    }
    
    [self registerNotifaction];
    
    [GMSServices provideAPIKey:@"AIzaSyAIJ7r2eJCRsSIqACaORYKA7iXkcwQ6TKg"];
    
    /*
    DispatchBackground(^{
        while (true) {
            DispatchMainSafe(^{
                NSLog(@"Google Map Demo index: %zd state: %zd", self.index, [UIApplication sharedApplication].applicationState);
                self.index++;
            });
            sleep(1);
        }
    });
     */
    
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 5.0f;


    _locationManager.pausesLocationUpdatesAutomatically = true; // 是否允许系统自动停止位置更新， 如果系统认为有必要。 这里选是，省电
    _locationManager.allowsBackgroundLocationUpdates = false; // 是否允许后台模式更新，这里我们使用region方案。 不需要始终后台更新， 只需要离开区域时，系统激活自己，执行一段代码就可以。
    
    [self.locationManager.monitoredRegions enumerateObjectsUsingBlock:^(__kindof CLRegion * _Nonnull obj, BOOL * _Nonnull stop) {
        [self.locationManager stopMonitoringForRegion:obj];
    }];
    
    // 申请始终定位权限
    [_locationManager requestAlwaysAuthorization];
    // 或者申请使用应用期间权限
//     [_locationManager requestWhenInUseAuthorization];

    // 最后需要在确定权限获取完成之后调用开启定位方法
     [_locationManager startUpdatingLocation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.locationManager stopUpdatingLocation];
    });
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(30.507544369000442,114.4133872013031);
    
//    CLLocationCoordinate2D location2 = [JZLocationConverter gcj02ToWgs84:location];
    
    
    // 设置区域半径
    CLLocationDistance radius = 200;
    // 使用前必须判定当前的监听区域半径是否大于最大可被监听的区域半径
    if(radius > self.locationManager.maximumRegionMonitoringDistance) {
        radius = self.locationManager.maximumRegionMonitoringDistance;
    }
    // 设置id
    NSString *identifier = [NSString stringWithFormat:@"%f , %f", location.latitude, location.longitude];
    // 使用CLCircularRegion创建一个圆形区域，
    CLRegion *fkit = [[CLCircularRegion alloc] initWithCenter:location
                                                       radius:radius
                                                   identifier:identifier];
    // 开始监听fkit区域
    [self.locationManager startMonitoringForRegion:fkit];
    
    
    // 被区域监测唤醒
    // 我在模拟器测试，更改地理位置时，launchOptions数据为空
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        NSLog(@"区域监测唤醒");
    }
    
    return YES;
}

// 注册通知
- (void)registerNotifaction {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        NSLog(@"注册通知成功");
    }];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"获取位置更新 %@", locations);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"失败 %@", [error localizedDescription]);
}

// 进入指定区域以后将弹出提示框提示用户
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
//    NSString *msg = [NSString stringWithFormat:@"Check-In \n Enter Region %@", region.identifier];
//    [self dealAlertWithStr:msg];
    
    [self mapVC].checkState = 1;
}

// 离开指定区域以后将弹出提示框提示用户
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
//    NSString *msg = [NSString stringWithFormat:@"Check-Out \n exit Region %@", region.identifier];
//    [self dealAlertWithStr:msg];
    
    [self mapVC].checkState = 0;
}

// 监听区域失败时调用
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"开始监听");
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"监听区域失败 : %@", error);
}

- (void)dealAlertWithStr:(NSString *)msg {
    NSLog(@"%@", msg);
    
    // 程序在后台
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self registerNotificationWithMsg:msg];
    } else { // 程序在前台
        [self alertWithMsg:msg];
    }
}


// 当前状态
- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region {
    NSString *str = nil;
    switch (state) {
        case CLRegionStateInside:
            str = [NSString stringWithFormat:@"在圈内 %@", region.identifier];
            break;
        case CLRegionStateOutside:
            str = [NSString stringWithFormat:@"在圈外 %@", region.identifier];
            break;
        case CLRegionStateUnknown:
            str = [NSString stringWithFormat:@"未知 %@", region.identifier];
            break;
        default:
            break;
    }
//    [self alertWithMsg:str];
}

// 本地通知
- (void)registerNotificationWithMsg:(NSString *)msg {
    // 使用 UNUserNotificationCenter 来管理通知
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    // 需创建一个包含待通知内容的 UNMutableNotificationContent 对象
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"通知"
                                                          arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:msg
                                                         arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    NSInteger alerTime = 1;
    // 在 alertTime 后推送本地推送
    UNTimeIntervalNotificationTrigger *trigger =
    [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:alerTime
                                                       repeats:NO];
    UNNotificationRequest* request =
    [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
                                         content:content
                                         trigger:trigger];
    
    //添加推送成功后的处理！
    [center addNotificationRequest:request withCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"添加推送失败 error : %@", error);
        } else {
            NSLog(@"添加推送成功");
        }
    }];
}

- (void)alertWithMsg:(NSString *)msg {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@"通知"
                                        message:msg
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alert addAction:action];
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [vc presentViewController:alert animated:YES completion:nil];
}

- (GoogleMapViewController *)mapVC {
    return self.window.rootViewController;
}
@end

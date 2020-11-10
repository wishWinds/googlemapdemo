//
//  ViewController.m
//  GoogleMapDemo
//
//  Created by shupeng on 2020/11/9.
//

#import "ViewController.h"
#import "GoogleMapViewController.h"
#import <SPUIKit/SPUIKit.h>
#import <SPUtilities/SPUtilities.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)googleMapButtonPressed:(id)sender {
    GoogleMapViewController *vc = STBDMainVC([GoogleMapViewController className]);
    [self.navigationController pushViewController:vc animated:true];
}

@end

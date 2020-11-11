//
//  ViewController.m
//  GoogleMapDemo
//
//  Created by shupeng on 2020/11/9.
//

#import "ViewController.h"
#import "GoogleMapViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)googleMapButtonPressed:(id)sender {
    GoogleMapViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GoogleMapViewController"];
    [self.navigationController pushViewController:vc animated:true];
}

@end

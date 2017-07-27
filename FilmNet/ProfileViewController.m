//
//  ProfileViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/27/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "ProfileViewController.h"
#import "SettingsViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedSettings:(id)sender {
    
    SettingsViewController *vc = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

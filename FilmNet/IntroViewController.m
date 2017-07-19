//
//  IntroViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/19/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "IntroViewController.h"
#import "AppDelegate.h"

#import "SignupViewController.h"
#import "LoginViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([self checkUserAuthenticated]) {
        [self presentHome];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (IBAction)tappedLogin:(id)sender {
    LoginViewController *vc = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)tappedSignup:(id)sender {
    SignupViewController *vc = [[SignupViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)presentHome {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITableViewController *tvc = [sb instantiateViewControllerWithIdentifier:@"MainTabViewController"];
    tvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:tvc animated:YES completion:NULL];
}

#pragma mark - Authentication

- (BOOL)checkUserAuthenticated {
    if ([FIRAuth auth].currentUser) {
        return YES;
    } else {
        return NO;
    }
}

@end

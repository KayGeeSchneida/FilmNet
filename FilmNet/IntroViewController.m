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
    
    [self checkUserAuthenticated];
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

- (void)checkUserAuthenticated {
    
    if ([FIRAuth auth].currentUser) {
        
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        [[[[[FIRDatabase database] reference] child:kUsers] child:userID] observeSingleEventOfType:FIRDataEventTypeValue
                                                           withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
         {
             if ([snapshot hasChildren] &&
                 [snapshot.value[kUserEmail] length] > 0) {
                 [self presentHome];
             } else {
                 // No valid user
             }
             
         } withCancelBlock:^(NSError * _Nonnull error) {
             NSLog(@"%@", error.localizedDescription);
         }];
    }
}

@end

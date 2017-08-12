//
//  RoleViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/20/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "RoleViewController.h"
#import "LocationViewController.h"
#import "RoleTableViewController.h"
#import "ComingSoonHelper.h"
#import "FNButton.h"

@interface RoleViewController () <RoleTableViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UIView *tableHolder;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet FNButton *primaryRoleButton;
@property (nonatomic, weak) IBOutlet FNButton *secondaryRoleButton;
@property (nonatomic, weak) IBOutlet FNButton *interestsButton;
@property (nonatomic, weak) IBOutlet FNButton *nextButton;

@property (nonatomic, strong) RoleTableViewController *roleTVC;

@end

@implementation RoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self additionalSetup];

    [self toggleTableVisable];
    
    [self setupRoleTVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    self.roleTVC.delegate = nil;
}

#pragma mark - Additional Setup

- (void)additionalSetup {
    
    [self.primaryRoleButton setFnButtonStyle:FNButtonStyleWhiteBordered];
    [self.secondaryRoleButton setFnButtonStyle:FNButtonStyleWhiteBordered];
    [self.interestsButton setFnButtonStyle:FNButtonStyleWhiteBordered];
    
    [self.nextButton setFnButtonStyle:FNButtonStyleGreen];
}

#pragma mark - Role TVC

- (void)setupRoleTVC {
    
    self.roleTVC = [[RoleTableViewController alloc] init];
    self.tableView.delegate = self.roleTVC;
    self.tableView.dataSource = self.roleTVC;
    self.roleTVC.delegate = self;
}

- (void)rolesTableView:(UITableView *)tableView didSelectRole:(NSString *)role {
    [self.primaryRoleButton setTitle:role forState:(UIControlStateNormal)];
    [self.primaryRoleButton setTitleColor:COLOR_Green forState:UIControlStateNormal];
    [self.userData setValue:role
                     forKey:kPrimaryRole];
    [self toggleTableVisable];
    self.nextButton.enabled = YES;
}

- (void)toggleTableVisable {
    [self.tableHolder setHidden:!self.tableHolder.hidden];
}

#pragma mark - User Interaction

- (IBAction)tappedPrimaryRole:(id)sender {
    [self toggleTableVisable];
}

- (IBAction)tappedSecondaryRole:(id)sender {
    [ComingSoonHelper showSecondaryRolesComingSoonInViewController:self];
}

- (IBAction)tappedInterests:(id)sender {
    [ComingSoonHelper showInterestsComingSoonInViewController:self];
}

- (IBAction)tappedNext:(id)sender {
    [self navigateToLocationViewController];
}

- (void)navigateToLocationViewController {
    LocationViewController *vc = [[LocationViewController alloc] init];
    vc.userData = self.userData;
    [self.navigationController pushViewController:vc animated:YES];
}

@end

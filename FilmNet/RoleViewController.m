//
//  RoleViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/20/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "RoleViewController.h"
#import "LocationViewController.h"

@interface RoleViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIView *tableHolder;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *primaryRoleButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;

@property (nonatomic, strong) NSArray *roles;

@end

@implementation RoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.roles = ROLES;
    
    [self toggleTableVisable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - User Interaction

- (IBAction)tappedPrimaryRole:(id)sender {
    [self toggleTableVisable];
}

- (void)toggleTableVisable {
    [self.tableHolder setHidden:!self.tableHolder.hidden];
}

- (IBAction)tappedNext:(id)sender {
    [self navigateToLocationViewController];
}

- (void)navigateToLocationViewController {
    LocationViewController *vc = [[LocationViewController alloc] init];
    vc.userData = self.userData;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.roles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = _roles[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.primaryRoleButton setTitle:_roles[indexPath.row] forState:(UIControlStateNormal)];
    [self.userData setValue:_roles[indexPath.row]
                     forKey:kPrimaryRole];
    [self toggleTableVisable];
    self.nextButton.enabled = YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

@end

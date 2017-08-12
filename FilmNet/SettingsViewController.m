//
//  SettingsViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/27/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "ComingSoonHelper.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *tableview;

@property (nonatomic, strong) NSArray *settings;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.settings = @[@"FAQ",@"Terms & Conditions",@"Contact Us",@"Delete Account",@"Log Out"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    [cell.textLabel setText:self.settings[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [ComingSoonHelper showFeatureComingSoon:@"FAQ" inViewController:self];
            break;
        case 1:
            [ComingSoonHelper showFeatureComingSoon:@"Terms & Conditions" inViewController:self];
            break;
        case 2:
            [ComingSoonHelper showFeatureComingSoon:@"Contact Us" inViewController:self];
            break;
        case 3:
            [ComingSoonHelper showFeatureComingSoon:@"Delete Account" inViewController:self];
            break;
        case 4:
            [self logout];
            break;
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

#pragma mark - Actions

- (void)logout {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        NSLog(@"Error signing out: %@", signOutError);
        return;
    } else {
        [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
    }
}

@end

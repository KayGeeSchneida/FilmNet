//
//  RoleTableViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/27/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "RoleTableViewController.h"

#import "Constants.h"

@interface RoleTableViewController ()

@property (nonatomic, strong) NSArray *roles;

@end

@implementation RoleTableViewController

- (id)init {
    self = [super init];
    if (self) {
        self.roles = ROLES;
    }
    return self;
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
    
    cell.textLabel.textColor = COLOR_DarkGray;
    cell.backgroundColor = COLOR_AlmostWhite;
    cell.textLabel.font = [UIFont fontWithName:FONT_ApercuPro size:15.0];
    
    cell.textLabel.text = _roles[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate) {
        [self.delegate rolesTableView:tableView didSelectRole:_roles[indexPath.row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

@end

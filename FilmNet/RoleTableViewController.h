//
//  RoleTableViewController.h
//  FilmNet
//
//  Created by Keith Schneider on 7/27/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RoleTableViewControllerDelegate <NSObject>

- (void)rolesTableView:(UITableView *)tableView didSelectRole:(NSString *)role;

@end

@interface RoleTableViewController : UITableViewController

@property (nonatomic, assign) NSObject <RoleTableViewControllerDelegate> *delegate;

@end

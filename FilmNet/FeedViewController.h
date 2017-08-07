//
//  FeedViewController.h
//  FilmNet
//
//  Created by Keith Schneider on 7/20/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BaseViewController.h"
#import "AppDelegate.h"

@interface FeedViewController : UIViewController
@property (nonatomic, strong) FIRDatabaseReference *feedReference;
@property (nonatomic, assign) BOOL shouldShowNavBar;
@end

//
//  AppDelegate.h
//  FilmNet
//
//  Created by Keith Schneider on 7/19/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

#define ARC4RANDOM_MAX      0x100000000

@import Firebase;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;

@end


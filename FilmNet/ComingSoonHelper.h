//
//  ComingSoonHelper.h
//  FilmNet
//
//  Created by Keith Schneider on 8/12/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ComingSoonHelper : NSObject

+ (void)showSearchComingSoonInViewController:(UIViewController *)vc;
+ (void)showMessageComingSoonInViewController:(UIViewController *)vc;
+ (void)showSecondaryRolesComingSoonInViewController:(UIViewController *)vc;
+ (void)showInterestsComingSoonInViewController:(UIViewController *)vc;
+ (void)showFeatureComingSoon:(NSString *)feature inViewController:(UIViewController *)vc;

@end

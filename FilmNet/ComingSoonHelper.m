//
//  ComingSoonHelper.m
//  FilmNet
//
//  Created by Keith Schneider on 8/12/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "ComingSoonHelper.h"
#import "Constants.h"

@implementation ComingSoonHelper

+ (void)showComingSoonAlertWithMessage:(NSString *)message inViewController:(UIViewController *)vc {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Coming Soon!"
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction
                               actionWithTitle:kAlertOK
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {}];
    
    [alert addAction:okButton];
    
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)showSearchComingSoonInViewController:(UIViewController *)vc {
 
    NSString *message = @"The search feature will allow you to find other users based on their name or primary role. Additionally, once project creation has been added, you will be able to search for projects based on their name or what roles they need filled.";
    
    [self showComingSoonAlertWithMessage:message inViewController:vc];
}

+ (void)showMessageComingSoonInViewController:(UIViewController *)vc {
    
    NSString *message = @"The message feature will allow you to message back and forth with other users. Additionally, once project creation has been added, you will be able to post messages to a group of other users involved in a project.";
    
    [self showComingSoonAlertWithMessage:message inViewController:vc];
}

+ (void)showFeatureComingSoon:(NSString *)feature inViewController:(UIViewController *)vc {
    
    NSString *message = [NSString stringWithFormat:@"%@ is coming soon...", feature];
    
    [self showComingSoonAlertWithMessage:message inViewController:vc];
}

@end

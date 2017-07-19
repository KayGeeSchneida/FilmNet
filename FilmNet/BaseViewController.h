//
//  BaseViewController.h
//  FilmNet
//
//  Created by Keith Schneider on 7/19/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDeviceWidth    [[UIScreen mainScreen] bounds].size.width
#define kDeviceHeight   [[UIScreen mainScreen] bounds].size.height
#define kStatusHeight   [UIApplication sharedApplication].statusBarFrame.size.height

@interface BaseViewController : UIViewController

// Defaults to YES, set to NO to disable
@property (nonatomic, assign) BOOL dismissKeyboardOnTap;

// Bottom space is the content view's lower constraint
// The keyboard will push this up and down
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *contentViewBottomSpace;

// For additional keyboard did show logic in subclasses (be sure to call SUPER)
- (void)keyboardWillShow:(NSNotification *)notification;

// For additional keyboard did show logic in subclasses (be sure to call SUPER)
- (void)keyboardDidShow:(NSNotification *)notification;

@end

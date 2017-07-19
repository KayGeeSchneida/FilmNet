//
//  BaseViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/19/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) UITapGestureRecognizer *dismissKeyboardGesture;
@property (nonatomic, assign) BOOL keyboardIsShowing;
@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Defaults to YES
    self.dismissKeyboardOnTap = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self observeKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeObserveKeyboardNotifications];
}

#pragma mark - Keyboard

- (void)observeKeyboardNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeObserveKeyboardNotifications
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    
    self.keyboardIsShowing = YES;
    self.dismissKeyboardGesture = [self keyboardDismissGestureRecognizer];;
    if (self.dismissKeyboardGesture && self.dismissKeyboardOnTap) {
        [[self dismissKeyboardGestureRecognizerParent] addGestureRecognizer:self.dismissKeyboardGesture];
    }
}
- (void)keyboardDidHide:(NSNotification *)notification {

    self.keyboardIsShowing = NO;
    if (self.dismissKeyboardGesture && self.dismissKeyboardOnTap) {
        [[self dismissKeyboardGestureRecognizerParent] removeGestureRecognizer:self.dismissKeyboardGesture];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.contentViewBottomSpace.constant = keyboardFrame.size.height;
    
    if (!self.keyboardIsShowing) {
        // Keyboard not yet showing, so animate the transition
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.25f animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.contentViewBottomSpace.constant = 0.0f;
    
    if (self.keyboardIsShowing) {
        // Keyboard is indeed showing, so animate the transition
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.25f animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (UITapGestureRecognizer *)keyboardDismissGestureRecognizer
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
    tapGestureRecognizer.delegate = self;
    return tapGestureRecognizer;
}

- (UIView *)dismissKeyboardGestureRecognizerParent
{
    return self.view;
}

- (void)dismissKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

@end

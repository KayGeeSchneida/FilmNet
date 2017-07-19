//
//  LoginViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/19/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupScrollContent];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Additional Setup

- (void)setupScrollContent
{
    float scrollContentHeight = self.contentView.frame.size.height;
    self.contentView.frame = CGRectMake(0, 0, kDeviceWidth, scrollContentHeight);
    [self.scrollView addSubview:self.contentView];
    self.scrollView.contentSize = CGSizeMake(kDeviceWidth, scrollContentHeight);
}

#pragma mark - Log In

- (IBAction)tappedLogIn:(id)sender {
    [self login];
}

- (void)login {
    
    if (![self validateEmail:self.emailField.text]) {
        [self showAlertWithMessage:@"You must enter a valid email to log in." andSuccess:NO];
    } else if (self.passwordField.text.length < 8) {
        [self showAlertWithMessage:@"You must enter a password of at least 8 characters to log in." andSuccess:NO];
    } else {
        [self sendLoginRequest];
    }
}

- (void)sendLoginRequest {
    [[FIRAuth auth] signInWithEmail:self.emailField.text
                           password:self.passwordField.text
                         completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                             
                             if (user) {
                                 NSString *message = [NSString stringWithFormat:@"Log in with email %@ successful.",
                                                      self.emailField.text];
                                 
                                 [self showAlertWithMessage:message andSuccess:YES];
                             } else {
                                 NSString *message = [error.userInfo valueForKey:@"NSLocalizedDescription"];
                                 
                                 [self showAlertWithMessage:message andSuccess:NO];
                                 
                             }
                             
                         }];
}

#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)message andSuccess:(BOOL)success {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Log In"
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction
                               actionWithTitle:@"Got It!"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   if (success) {
                                       [self.navigationController popViewControllerAnimated:YES];
                                   }
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.emailField == textField) {
        [self.passwordField becomeFirstResponder];
    } else if (self.passwordField == textField) {
        
        [textField resignFirstResponder];
        [self login];
    }
    return YES;
}

#pragma mark - Validations

- (BOOL)validateEmail:(NSString *)email
{
    if ([email length] == 0) {
        return NO;
    }
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
}

@end

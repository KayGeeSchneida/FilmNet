//
//  SignupViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/19/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "SignupViewController.h"
#import "AppDelegate.h"
#import "RoleViewController.h"

@interface SignupViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UITextField *confirmField;

@end

@implementation SignupViewController

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

#pragma mark - Sign Up

- (IBAction)tappedSignUp:(id)sender {
    [self signup];
}

- (void)signup {
    
    if (self.nameField.text.length == 0) {
        [self showAlertWithMessage:@"You must enter a name to sign up." andSuccess:NO];
    } else if (![self validateEmail:self.emailField.text]) {
        [self showAlertWithMessage:@"You must enter a valid email to sign up." andSuccess:NO];
    } else if (self.passwordField.text.length < 8) {
        [self showAlertWithMessage:@"You must enter a password of at least 8 characters to sign up." andSuccess:NO];
    } else if (![self.confirmField.text isEqualToString:self.passwordField.text]) {
        [self showAlertWithMessage:@"Your password and confirmation do not match." andSuccess:NO];
    } else {
        [self sendSignupRequest];
    }
}

- (void)sendSignupRequest {
    [[FIRAuth auth] createUserWithEmail:self.emailField.text
                               password:self.passwordField.text
                             completion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
                                 
                                 if (user) {
                                     
                                     FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
                                     changeRequest.displayName = self.nameField.text;
                                     [changeRequest commitChangesWithCompletion:^(NSError *_Nullable error) {
                                         
                                         NSString *message = [NSString stringWithFormat:@"User with email %@ created.",
                                                              self.emailField.text];
                                         
                                         [self showAlertWithMessage:message andSuccess:YES];
                                         
                                     }];
                                     
                                 } else {
                                     NSString *message = [error.userInfo valueForKey:@"NSLocalizedDescription"];
                                     
                                     [self showAlertWithMessage:message andSuccess:NO];

                                 }
                                 
                             }];
}

- (void)navigateToRoleViewController {
    RoleViewController *vc = [[RoleViewController alloc] init];
    vc.userData = @{kUserEmail: self.emailField.text,
                    kDisplayName: self.nameField.text}.mutableCopy;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)message andSuccess:(BOOL)success {
    
    UIAlertController *alert = [UIAlertController
                                 alertControllerWithTitle:@"Sign Up"
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction
                                actionWithTitle:@"Got It!"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    if (success) {
                                        [self navigateToRoleViewController];
                                    }
                                }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.nameField == textField) {
        [self.emailField becomeFirstResponder];
    } else if (self.emailField == textField) {
        [self.passwordField becomeFirstResponder];
    } else if (self.passwordField == textField) {
        [self.confirmField becomeFirstResponder];
    } else if (self.confirmField == textField) {
        
        [textField resignFirstResponder];
        [self signup];

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

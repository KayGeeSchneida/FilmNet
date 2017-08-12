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
#import "ValidationsUtil.h"
#import "FNButton.h"

@interface SignupViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UITextField *confirmField;
@property (nonatomic, weak) IBOutlet FNButton *signupButton;
@property (nonatomic, weak) IBOutlet UILabel *signupLabel;

@end

@implementation SignupViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupScrollContent];
    
    [self.signupButton setFnButtonStyle:FNButtonStyleGreen];
    
    self.signupLabel.font = [UIFont fontWithName:FONT_GraphikStencilXQ size:40];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    } else if (![ValidationsUtil validateEmail:self.emailField.text]) {
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
                                         
                                         NSString *message = [NSString stringWithFormat:@"User created!"];
                                         
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
                                actionWithTitle:kAlertOK
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

@end

//
//  SignupViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/19/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "SignupViewController.h"

@interface SignupViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UITextField *nameField;
@property (nonatomic, weak) IBOutlet UITextField *emailField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@property (nonatomic, weak) IBOutlet UITextField *confirmField;

@end

@implementation SignupViewController

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

- (void)setupScrollContent
{
    float scrollContentHeight = self.contentView.frame.size.height;
    self.contentView.frame = CGRectMake(0, 0, kDeviceWidth, scrollContentHeight);
    [self.scrollView addSubview:self.contentView];
    self.scrollView.contentSize = CGSizeMake(kDeviceWidth, scrollContentHeight);
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
        // TODO: Send Sign Up request
        [textField resignFirstResponder];
    }
    return YES;
}

@end

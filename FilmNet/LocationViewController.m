//
//  LocationViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/20/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "LocationViewController.h"
#import "AppDelegate.h"

@interface LocationViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UITextField *zipField;
@property (nonatomic, weak) IBOutlet UIButton *finishButton;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

@implementation LocationViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupScrollContent];
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

#pragma mark - Location Services

- (IBAction)tappedEnableLocationServices:(id)sender {
    [self showAlertWithMessage:@"Location services coming soon!" andSuccess:NO];
}

#pragma mark - Finish

- (IBAction)tappedFinish:(id)sender {
    [self finish];
}

- (void)finish {
    
    if (![self validateZip:self.zipField.text]) {
        [self showAlertWithMessage:@"You must enter a valid zip code to finish." andSuccess:NO];
    } else {
        [self finishSavingUserData];
    }
    
}

- (void)finishSavingUserData {
    
    [self.userData setValue:self.zipField.text
                     forKey:@"zipcode"];
    
    self.ref = [[FIRDatabase database] reference];
    
    [[[_ref child:@"users"] child:[FIRAuth auth].currentUser.uid]
     setValue:self.userData];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)message andSuccess:(BOOL)success {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Location"
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction
                               actionWithTitle:@"Got It!"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   if (success) {
                                       [self.navigationController popToRootViewControllerAnimated:YES];
                                   }
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.finishButton.enabled = [self validateZip:
                                 [textField.text stringByReplacingCharactersInRange:range withString:string]];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.zipField == textField) {
        [textField resignFirstResponder];
        [self finish];
    }
    return YES;
}

#pragma mark - Validations

- (BOOL)validateZip:(NSString *)zip
{
    if ([zip length] == 0) {
        return NO;
    }
    
    NSString *postcodeRegex = @"^(\\d{5}(-\\d{4})?|[a-z]\\d[a-z][- ]*\\d[a-z]\\d)$";
    NSPredicate *postcodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", postcodeRegex];
    BOOL isValid = [postcodeTest evaluateWithObject:zip];
    return isValid;
}

@end

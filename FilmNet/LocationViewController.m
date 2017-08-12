//
//  LocationViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/20/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>

#import "LocationViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "ValidationsUtil.h"

@interface LocationViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UITextField *zipField;
@property (nonatomic, weak) IBOutlet UIButton *finishButton;

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
    
    if (![ValidationsUtil validateZip:self.zipField.text]) {
        [self showAlertWithMessage:@"You must enter a valid zip code to finish." andSuccess:NO];
    } else {
        [self fetchLocationDataWithZip:self.zipField.text];
    }
    
}

- (void)fetchLocationDataWithZip:(NSString*)zip
{
    CLGeocoder* geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressDictionary:@{(NSString*)kABPersonAddressZIPKey : zip}
                     completionHandler:^(NSArray *placemarks, NSError *error) {
                         if ([placemarks count] > 0) {
                             CLPlacemark* placemark = [placemarks objectAtIndex:0];
                             
                             NSString* city = placemark.addressDictionary[(NSString*)kABPersonAddressCityKey];
                             NSString* state = placemark.addressDictionary[(NSString*)kABPersonAddressStateKey];
                             NSString* country = placemark.addressDictionary[(NSString*)kABPersonAddressCountryCodeKey];
                             
                             [self.userData setValue:city
                                              forKey:kCity];
                             [self.userData setValue:state
                                              forKey:kState];
                             [self.userData setValue:country
                                              forKey:kCountry];
                             
                             [self finishSavingUserData];
                         } else {
                             // TODO: Handle Lookup Failed
                         }
                     }];
}

- (void)finishSavingUserData {
    
    [self.userData setValue:self.zipField.text
                     forKey:kZipcode];
    
    [[[[[FIRDatabase database] reference] child:kUsers] child:[FIRAuth auth].currentUser.uid] setValue:self.userData];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)message andSuccess:(BOOL)success {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Location"
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction
                               actionWithTitle:kAlertOK
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
    self.finishButton.enabled = [ValidationsUtil validateZip:
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

@end

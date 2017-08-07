//
//  ProfileViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/27/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@import ImagePicker;

#import "UIImageView+AFNetworking.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "RoleTableViewController.h"
#import "ValidationsUtil.h"
#import "ReelViewController.h"
#import "FeedViewController.h"

@interface ProfileViewController ()
<RoleTableViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, ImagePickerDelegate>

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, weak) IBOutlet UITextField *username;
@property (nonatomic, weak) IBOutlet UIButton *role;
@property (nonatomic, weak) IBOutlet UITextField *location;
@property (nonatomic, weak) IBOutlet UIImageView *userimage;
@property (nonatomic, weak) IBOutlet UIButton *selectUserImage;
@property (nonatomic, weak) IBOutlet UIImageView *reelimage;
@property (nonatomic, weak) IBOutlet UITextView *details;
@property (nonatomic, weak) IBOutlet UILabel *detailsPrompt;

@property (nonatomic, weak) IBOutlet UIButton *connections;
@property (nonatomic, weak) IBOutlet UIButton *recommendations;

@property (nonatomic, weak) IBOutlet UIView *videoContainer;
@property(nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

@property (nonatomic, weak) IBOutlet UIView *tableHolder;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) RoleTableViewController *roleTVC;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDataSnapshot *userSnapshot;

@end

@implementation ProfileViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ref = [[FIRDatabase database] reference];
    
    [self setupRoleTVC];
    
    [self setupScrollContent];
    
    [self additionalViewSetup];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self prepopulateUserData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.videoPlayerViewController.moviePlayer pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    self.roleTVC.delegate = nil;
}

#pragma mark - Role TVC

- (void)setupRoleTVC {
    self.roleTVC = [[RoleTableViewController alloc] init];
    self.tableView.delegate = self.roleTVC;
    self.tableView.dataSource = self.roleTVC;
    [self.tableView reloadData];
    self.roleTVC.delegate = self;
    [self toggleTableVisable];
}

- (void)rolesTableView:(UITableView *)tableView didSelectRole:(NSString *)role {
    [self.role setTitle:role forState:(UIControlStateNormal)];
    [[[[_ref child:kUsers] child:[FIRAuth auth].currentUser.uid] child:kPrimaryRole] setValue:role];
    [self toggleTableVisable];
}

- (void)toggleTableVisable {
    [self.tableHolder setHidden:!self.tableHolder.hidden];
}

#pragma mark - Additional Setup

- (void)setupScrollContent
{
    float scrollContentHeight = self.scrollView.frame.size.height;
    self.contentView.frame = CGRectMake(0, 0, kDeviceWidth, scrollContentHeight);
    [self.scrollView addSubview:self.contentView];
    self.scrollView.contentSize = CGSizeMake(kDeviceWidth, scrollContentHeight);
}

- (void)additionalViewSetup {
    
    [self.userimage setImage:[UIImage imageNamed:@"defaultuserimage"]];
    self.userimage.layer.cornerRadius = self.userimage.frame.size.width/2;
    self.userimage.clipsToBounds = YES;
    
    [self.reelimage setImage:[UIImage imageNamed:@"defaultreelimage"]];
    self.reelimage.clipsToBounds = YES;
    self.reelimage.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.reelimage.layer.borderWidth = 1.0f;
    
    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:nil];
    [self.videoPlayerViewController presentInView:self.videoContainer];
    [self.videoPlayerViewController.moviePlayer prepareToPlay];
}

#pragma mark - Data

- (void)prepopulateUserData {
    
    NSString *userID = [FIRAuth auth].currentUser.uid;
    
    [[[_ref child:kUsers] child:userID] observeSingleEventOfType:FIRDataEventTypeValue
                                                       withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
    {
        self.userSnapshot = snapshot;
        [self setUserData];
                                                           
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)setUserData {
    self.username.text = self.userSnapshot.value[kDisplayName];
    [self.role setTitle:self.userSnapshot.value[kPrimaryRole] forState:UIControlStateNormal];
    self.location.text = self.userSnapshot.value[kZipcode];
    self.details.text = self.userSnapshot.value[kUserDetails];
    self.detailsPrompt.hidden = self.details.text.length > 0;
    
    if (self.userSnapshot.value[kProfilePic]) {
        [self.userimage setImageWithURL:[NSURL URLWithString:self.userSnapshot.value[kProfilePic]]];
    }
    
    NSArray *recommendations = self.userSnapshot.value[kRecommendedBy];
    NSString *recString = [NSString stringWithFormat:@"%ld Recommendations", recommendations.count];
    [self.recommendations setTitle:recString forState:UIControlStateNormal];
    
    NSArray *connections = self.userSnapshot.value[kConnections];
    NSString *conString = [NSString stringWithFormat:@"%ld Connections", connections.count];
    [self.connections setTitle:conString forState:UIControlStateNormal];
    
    if (self.userSnapshot.value[kReelURL]) {
        [self.videoPlayerViewController setVideoIdentifier:self.userSnapshot.value[kReelURL]];
    } else {
        [self.videoPlayerViewController setVideoIdentifier:DEFAULT_reel];
    }
    
    [self.videoPlayerViewController.moviePlayer play];
}

#pragma mark - User Image

- (void)uploadUserImage:(UIImage *)userimage {
    
    CGRect rect = CGRectMake(0,0,512,512);
    UIGraphicsBeginImageContext( rect.size );
    [userimage drawInRect:rect];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImagePNGRepresentation(resized);
    
    FIRStorage *storage = [FIRStorage storage];

    FIRStorageReference *storageRef = [storage reference];

    NSString *userID = [FIRAuth auth].currentUser.uid;

    NSString *userPicPath = [NSString stringWithFormat:@"images/profilepics/%@.png", userID];
    
    FIRStorageReference *profilePicRef = [storageRef child:userPicPath];
    
    [profilePicRef putData:imageData
                  metadata:nil
                completion:^(FIRStorageMetadata *metadata,
                             NSError *error) {
                    if (error != nil) {
                        // Uh-oh, an error occurred!
                    } else {
                        // Metadata contains file metadata such as size, content-type, and download URL.
                        NSURL *downloadURL = metadata.downloadURL;
                        [[[[_ref child:kUsers] child:[FIRAuth auth].currentUser.uid] child:kProfilePic] setValue:downloadURL.absoluteString];
                    }
                }];
}

- (void)loadUserImage {
    
    FIRStorage *storage = [FIRStorage storage];
    
    FIRStorageReference *storageRef = [storage reference];
    
    NSString *userID = [FIRAuth auth].currentUser.uid;
    
    NSString *userPicPath = [NSString stringWithFormat:@"images/profilepics/%@.png", userID];
    
    FIRStorageReference *profilePicRef = [storageRef child:userPicPath];

    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
    [profilePicRef dataWithMaxSize:1 * 1024 * 1024 completion:^(NSData *data, NSError *error){
        if (error != nil) {
            // Uh-oh, an error occurred!
        } else {
            // Data for "images/island.jpg" is returned
            UIImage *profilePic = [UIImage imageWithData:data];
            self.userimage.image = profilePic;
        }
    }];
}

#pragma mark - Alert

- (void)showAlertWithMessage:(NSString *)message andSuccess:(BOOL)success {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"My Profile"
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction
                               actionWithTitle:@"Got It!"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   if (success) {

                                   } else {
                                       [self setUserData];
                                   }
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)tappedSettings:(id)sender {
    
    SettingsViewController *vc = [[SettingsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)tappedPrimaryRole:(id)sender {
    [self toggleTableVisable];
}

- (IBAction)tappedSelectUserImage:(id)sender {
    ImagePickerController *ipc = [[ImagePickerController alloc] init];
    ipc.delegate = self;
    ipc.imageLimit = 1;
    [self.tabBarController presentViewController:ipc animated:YES completion:nil];
}

- (IBAction)tappedSelectReel:(id)sender {
    [self.videoPlayerViewController.moviePlayer stop];
    ReelViewController *vc = [[ReelViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)tappedRecommendations:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FeedViewController *vc = [sb instantiateViewControllerWithIdentifier:@"FeedViewController"];
    
    NSString *userID = [FIRAuth auth].currentUser.uid;
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",kUsers,userID,kRecommendedBy];
    vc.feedReference = [[FIRDatabase database] referenceWithPath:path];
    vc.title = @"Recommended By";
    
    vc.shouldShowNavBar = YES;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)tappedConnections:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FeedViewController *vc = [sb instantiateViewControllerWithIdentifier:@"FeedViewController"];
    
    NSString *userID = [FIRAuth auth].currentUser.uid;
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",kUsers,userID,kConnections];
    vc.feedReference = [[FIRDatabase database] referenceWithPath:path];
    vc.title = @"Connections";
    
    vc.shouldShowNavBar = YES;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.username == textField) {
        if (textField.text.length == 0) {
            [self showAlertWithMessage:@"You must enter a valid name to update." andSuccess:NO];
        } else {
            [[[[_ref child:kUsers] child:[FIRAuth auth].currentUser.uid] child:kDisplayName] setValue:textField.text];
        }
    } else if (self.location == textField) {
        if (![ValidationsUtil validateZip:self.location.text]) {
            [self showAlertWithMessage:@"You must enter a valid zip code to update." andSuccess:NO];
        } else {
            [[[[_ref child:kUsers] child:[FIRAuth auth].currentUser.uid] child:kZipcode] setValue:textField.text];
            [self fetchLocationDataWithZip:textField.text];
        }
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    self.detailsPrompt.hidden = YES;
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    self.detailsPrompt.hidden = self.details.text.length > 0;
    
    if (self.details.text.length) {
        [[[[_ref child:kUsers] child:[FIRAuth auth].currentUser.uid] child:kUserDetails] setValue:textView.text];
    }
}

#pragma mark - ImagePickerDelegate

- (void)wrapperDidPress:(ImagePickerController *)imagePicker images:(NSArray<UIImage *> *)images
{
    if (images.count > 0) {
        UIImage *profileImage = images[0];
        self.userimage.image = profileImage;
    }
    
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonDidPress:(ImagePickerController *)imagePicker images:(NSArray<UIImage *> *)images
{
    if (images.count > 0) {
        UIImage *profileImage = images[0];
        self.userimage.image = profileImage;
        [self uploadUserImage:profileImage];
    }
    
    [self.tabBarController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonDidPress:(ImagePickerController *)imagePicker
{

}

#pragma mark - Location

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
                             
                             NSString *uid = [FIRAuth auth].currentUser.uid;
                             [[[[_ref child:kUsers] child:uid] child:kCity] setValue:city];
                             [[[[_ref child:kUsers] child:uid] child:kState] setValue:state];
                             [[[[_ref child:kUsers] child:uid] child:kCountry] setValue:country];
                             
                         } else {
                             // TODO: Handle Lookup Failed
                         }
                         
                     }];
}

@end

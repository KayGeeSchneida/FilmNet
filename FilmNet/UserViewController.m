//
//  UserViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 8/7/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "UserViewController.h"
#import "UIImageView+AFNetworking.h"
#import <XCDYouTubeKit/XCDYouTubeKit.h>
#import "RecommendService.h"
#import "ConnectionService.h"
#import "FeedViewController.h"

@interface UserViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *primaryRoleLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet UIButton *connectionsButton;
@property (nonatomic, weak) IBOutlet UIButton *connectButton;
@property (nonatomic, weak) IBOutlet UIButton *recommendationsButton;
@property (nonatomic, weak) IBOutlet UIButton *recommendButton;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, weak) IBOutlet UIView *videoContainer;
@property (nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDataSnapshot *userSnapshot;

@end

@implementation UserViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ref = [[FIRDatabase database] reference];
    
    [self setupScrollContent];
    
    [self additionalViewSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];

    [self prepopulateUserData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.videoPlayerViewController.moviePlayer pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)tappedMessageButton
{
    NSLog(@"Message tapped");
}

- (IBAction)tappedRecommend:(id)sender
{
    [RecommendService recommendUserWithID:self.userID inViewController:self];
}

- (IBAction)tappedRecommendations:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FeedViewController *vc = [sb instantiateViewControllerWithIdentifier:@"FeedViewController"];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",kUsers,self.userID,kRecommendedBy];
    vc.feedReference = [[FIRDatabase database] referenceWithPath:path];
    vc.title = @"Recommended By";
    
    vc.shouldShowNavBar = YES;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)tappedConnect:(id)sender
{
    [ConnectionService connectToUserWithID:self.userID inViewController:self];
}

- (IBAction)tappedConnections:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FeedViewController *vc = [sb instantiateViewControllerWithIdentifier:@"FeedViewController"];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",kUsers,self.userID,kConnections];
    vc.feedReference = [[FIRDatabase database] referenceWithPath:path];
    vc.title = @"Connections";
    
    vc.shouldShowNavBar = YES;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController pushViewController:vc animated:YES];
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
    
    UIBarButtonItem *messageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(tappedMessageButton)];
    self.navigationItem.rightBarButtonItem = messageButton;
    
    [self.userImageView setImage:[UIImage imageNamed:@"defaultuserimage"]];
    self.userImageView.layer.cornerRadius = self.userImageView.frame.size.width/2;
    self.userImageView.clipsToBounds = YES;
    
    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:nil];
    [self.videoPlayerViewController presentInView:self.videoContainer];
    [self.videoPlayerViewController.moviePlayer prepareToPlay];
}

#pragma mark - Data

- (void)prepopulateUserData {
    
    FIRDatabaseReference *usersRef = [[FIRDatabase database] referenceWithPath:kUsers];
    
    [[usersRef child:self.userID] observeEventType:FIRDataEventTypeValue
                     withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         self.userSnapshot = snapshot;
         [self setUserData];
         
     } withCancelBlock:^(NSError * _Nonnull error) {
         NSLog(@"%@", error.localizedDescription);
     }];
}

- (void)setUserData {
    self.userNameLabel.text = self.userSnapshot.value[kDisplayName];
    self.primaryRoleLabel.text = self.userSnapshot.value[kPrimaryRole];
    
    NSString *location = [NSString stringWithFormat:@"%@, %@", self.userSnapshot.value[kCity], self.userSnapshot.value[kState]];
    self.locationLabel.text = location;
    
    self.descriptionLabel.text = self.userSnapshot.value[kUserDetails];
    if (self.userSnapshot.value[kProfilePic]) {
        [self.userImageView setImageWithURL:[NSURL URLWithString:self.userSnapshot.value[kProfilePic]]];
    }
    
    NSString *currentUserID = [FIRAuth auth].currentUser.uid;
    
    NSDictionary *recommendations = self.userSnapshot.value[kRecommendedBy];
    NSString *recString = [NSString stringWithFormat:@"%ld Recommendations", recommendations.count];
    [self.recommendationsButton setTitle:recString forState:UIControlStateNormal];
    
    BOOL hasRecommended = [recommendations valueForKey:currentUserID];
    [self.recommendButton setTitle:hasRecommended?@"Recommended!":@"Recommend?" forState:UIControlStateNormal];
    
    NSDictionary *connections = self.userSnapshot.value[kConnections];
    NSString *conString = [NSString stringWithFormat:@"%ld Connections", connections.count];
    [self.connectionsButton setTitle:conString forState:UIControlStateNormal];
    
    BOOL hasConnected = [connections valueForKey:currentUserID];
    BOOL hasRecievedRequest = [self.userSnapshot.value[kRequestsSent] valueForKey:currentUserID];
    BOOL hasSentRequest = [self.userSnapshot.value[kRequestsReceived] valueForKey:currentUserID];
    
    if (hasConnected) {
        [self.connectButton setTitle:@"Connected!" forState:UIControlStateNormal];
    } else if (hasRecievedRequest) {
        [self.connectButton setTitle:@"Accept Connect Request?" forState:UIControlStateNormal];
    } else if (hasSentRequest) {
        [self.connectButton setTitle:@"Connection Request Sent..." forState:UIControlStateNormal];
    } else {
        [self.connectButton setTitle:@"Connect?" forState:UIControlStateNormal];
    }
    
    if (self.userSnapshot.value[kReelURL]) {
        [self.videoPlayerViewController setVideoIdentifier:self.userSnapshot.value[kReelURL]];
    } else {
        [self.videoPlayerViewController setVideoIdentifier:DEFAULT_reel];
    }
    
    [self.videoPlayerViewController.moviePlayer play];
}

@end

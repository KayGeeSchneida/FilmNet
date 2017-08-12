//
//  FeedViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/20/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "FeedViewController.h"
#import "UserCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "UserViewController.h"
#import "RecommendService.h"
#import "ConnectionService.h"
#import "ComingSoonHelper.h"

@interface FeedViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UserCollectionViewCell *focusedCell;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDataSnapshot *userSnapshot;

@property (strong, nonatomic) NSMutableDictionary *users;
@property (strong, nonatomic) NSArray *keys;

@property (nonatomic, assign) BOOL isFirstLoad;

@end

@implementation FeedViewController

#pragma mark - View Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"Film Net";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self additionalViewSetup];
    
    self.isFirstLoad = YES;
    
    [self setupCollectionView];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];

    [self setupNotifications];
    
    [self fetchData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self.navigationController setNavigationBarHidden:!self.shouldShowNavBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.focusedCell) {
        [self.focusedCell.videoPlayerViewController.moviePlayer play];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.focusedCell.videoPlayerViewController.moviePlayer pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Additional Setup

- (void)additionalViewSetup {
    
    UIBarButtonItem *messageButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                   target:self
                                                                                   action:@selector(tappedSearch)];
    self.navigationItem.rightBarButtonItem = messageButton;
}

- (void)setupCollectionView {

    [self.collectionView registerClass:[UserCollectionViewCell class]
            forCellWithReuseIdentifier:@"UserCollectionViewCell"];
    
    UINib *cellNib = [UINib nibWithNibName:@"UserCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"UserCollectionViewCell"];

}

- (void)setupNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
}

#pragma mark - Data Helpers

- (NSSet *)keysForConnectionRequests {
    NSSet *connections = [NSSet setWithArray:[self.userSnapshot.value[kConnections] allKeys]];
    NSMutableSet *requests = [[NSSet setWithArray:[self.userSnapshot.value[kRequestsReceived] allKeys]] mutableCopy];
    [requests minusSet:connections];
    return requests;
}

- (NSSet *)keysForCommonConnectionsWithUser:(FIRDataSnapshot *)user {
    NSSet *thisUserConnections = [NSSet setWithArray:[user.value[kConnections] allKeys]];
    NSMutableSet *currentUserConnections = [NSMutableSet setWithArray:[self.userSnapshot.value[kConnections] allKeys]];
    [currentUserConnections intersectSet:thisUserConnections];
    return currentUserConnections;
}

- (NSSet *)keysForCommonConnectionsWithUser:(FIRDataSnapshot *)user excludingKeys:(NSSet *)keys {
    NSMutableSet *thisUserConnections = [[NSSet setWithArray:[user.value[kConnections] allKeys]] mutableCopy];
    [thisUserConnections minusSet:keys];
    return thisUserConnections;
}

#pragma mark - Feed Service Call

- (void)fetchData {
    
    self.ref = [[FIRDatabase database] reference];
    
    [self fetchCurrentUser];
}

- (void)fetchCurrentUser {
    
    NSString *userID = [FIRAuth auth].currentUser.uid;
    
    [[[_ref child:kUsers] child:userID] observeEventType:FIRDataEventTypeValue
                                               withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         self.userSnapshot = snapshot;
         
         [self fetchFeed];
         
//         NSLog(@"outstanding requests: %@", requests);
//         NSLog(@"current user snapshot: %@", self.userSnapshot);
         
     } withCancelBlock:^(NSError * _Nonnull error) {
         NSLog(@"%@", error.localizedDescription);
     }];
}

- (void)fetchFeed {
    
    // TODO: REMOVE THIS
    // Main feed is temporarily all users
    if (!self.feedReference) {
        self.feedReference = [[[FIRDatabase database] reference] child:kUsers];
    }
    
    if (self.feedReference) {
        
        [self.feedReference observeEventType:FIRDataEventTypeValue
                                   withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
         {
//         NSLog(@"snapshot: %@", snapshot);
             
             if ([snapshot hasChildren]) {
                 
                 self.keys = [snapshot.value allKeys];
                 [self.collectionView reloadData];
                 
                 [self populateFeed];
                 
//             NSLog(@"Feed Keys: %@", self.keys);
//             NSLog(@"Keys Count: %ld", self.keys.count);
                 
             }
         }];
        
    } else {
        
        [self fetchMainFeed];
    }
}

- (void)fetchMainFeed {
    
    // TODO: Refactor this to be more efficient
    
    // TODO: Pagination
    
    // 1) Create array for keys to be added to
    
    NSMutableArray *buildKeysArray = [[NSMutableArray alloc] init];
    
    // 2) Top keys should be users who have requested connections
    
    [buildKeysArray addObjectsFromArray:[[self keysForConnectionRequests] allObjects]];
    
    // 3) Grab user snapshots for all of current users connections
    
    [[ConnectionService feedReferenceForCurrentUserConnections] observeSingleEventOfType:FIRDataEventTypeValue
                                                        withBlock:^(FIRDataSnapshot * _Nonnull connectionSnapshot)
    {
        __block NSNumber *keyCount = [NSNumber numberWithUnsignedInteger:[[connectionSnapshot.value allKeys] count]];
        
        for (NSString *key in [connectionSnapshot.value allKeys]) {
            [[[self.ref child:kUsers] child:key] observeSingleEventOfType:FIRDataEventTypeValue
                                                                withBlock:^(FIRDataSnapshot * _Nonnull userSnapshot)
             {
                 // 4) Find common connections and add those keys (without doubling up)
                 // ** Don't add users already connected with either
                 
                 NSMutableSet *excludeKeys = [NSMutableSet setWithArray:buildKeysArray];
                 [excludeKeys addObjectsFromArray:[connectionSnapshot.value allKeys]];
                 
                 NSSet *addKeys = [self keysForCommonConnectionsWithUser:userSnapshot
                                                           excludingKeys:excludeKeys];

                 [buildKeysArray addObjectsFromArray:[addKeys allObjects]];
                 
                 keyCount = [NSNumber numberWithUnsignedInteger:[keyCount unsignedIntegerValue] - 1];
                 
                 if (keyCount.unsignedIntegerValue == 0) {
                     
                     // All keys accounted for
                     
                     FIRDatabaseQuery *recentPostsQuery = [[self.ref child:kUsers] queryLimitedToFirst:20];

                     [recentPostsQuery observeSingleEventOfType:FIRDataEventTypeValue
                                                         withBlock:^(FIRDataSnapshot * _Nonnull allSnapshot)
                      
                      {
                          
                          // 5) Add other users to fill out the end of the set
                          
                          NSMutableSet *allKeys = [[NSSet setWithArray:[allSnapshot.value allKeys]] mutableCopy];
                          [allKeys minusSet:[NSSet setWithArray:buildKeysArray]];
                          [buildKeysArray addObjectsFromArray:[allKeys allObjects]];
                          
                          // 6) Don't get yourself, that's silly
                          
                          NSString *userID = [FIRAuth auth].currentUser.uid;
                          if ([buildKeysArray containsObject:userID]) {
                              [buildKeysArray removeObject:userID];
                          }
                          
                          // 7) Set keys array with built array
                          
                          self.keys = buildKeysArray;
                          
                          // 8) Reload collection view for appropriate user count
                          
                          [self.collectionView reloadData];
                          
                          // 9) Grab each user data in turn for all keys
                          
                          [self populateFeed];
                          
                          // 10) Celebrate!
                          
                      } withCancelBlock:^(NSError * _Nonnull error) {
                          NSLog(@"%@", error.localizedDescription);
                      }];
                 }
   
             } withCancelBlock:^(NSError * _Nonnull error) {
                 
                 keyCount = [NSNumber numberWithUnsignedInteger:[keyCount unsignedIntegerValue] - 1];
                 
                 NSLog(@"%@", error.localizedDescription);
             }];
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
    
}

- (void)populateFeed {
    
    if (!self.users) {
        self.users = [[NSMutableDictionary alloc] init];
    }
    
    for (NSString *key in self.keys) {
        [[[self.ref child:kUsers] child:key] observeSingleEventOfType:FIRDataEventTypeValue
                                                           withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
         {
             [self.users setValue:snapshot forKey:key];
             NSInteger index = [self.keys indexOfObject:key];
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
             [self.collectionView reloadItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
             
         } withCancelBlock:^(NSError * _Nonnull error) {
             NSLog(@"%@", error.localizedDescription);
         }];
    }
}

#pragma mark - Actions

- (void)recommendTapped:(id)sender {
    
    NSString *userID = [self.keys objectAtIndex:[sender tag]];
    if (![userID isEqualToString:[FIRAuth auth].currentUser.uid]) {
        [RecommendService recommendUserWithID:userID inViewController:self];
    }
}

- (void)connectTapped:(id)sender {
    NSString *userID = [self.keys objectAtIndex:[sender tag]];
    if (![userID isEqualToString:[FIRAuth auth].currentUser.uid]) {
        [ConnectionService connectToUserWithID:userID inViewController:self];
    }
}

- (void)tappedSearch {
    [ComingSoonHelper showSearchComingSoonInViewController:self];
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.keys.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserCollectionViewCell *cell = (UserCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"UserCollectionViewCell" forIndexPath:indexPath];
    
    [self setupCell:cell atIndexPath:indexPath];
    
    NSString *key = [self.keys objectAtIndex:indexPath.row];
    FIRDataSnapshot *user = [self.users valueForKey:key];
    
    if (user) {
        
        [self mapUser:user toCell:cell];
        
        if (!self.focusedCell) {
            
            self.focusedCell = cell;
            
            if (self.isFirstLoad) {
                
                [self.focusedCell.videoPlayerViewController.moviePlayer play];
                self.isFirstLoad = NO;
            }
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kDeviceWidth, collectionView.frame.size.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *userID = [self.keys objectAtIndex:indexPath.row];

    if (![userID isEqualToString:[FIRAuth auth].currentUser.uid]) {
        UserViewController *vc = [[UserViewController alloc] init];
        vc.userID = userID;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Additional Cell Setup

- (void)setupCell:(UserCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    if (cell.recommendationsButton.allTargets.count == 0) {
        cell.recommendationsButton.userInteractionEnabled = NO;
        //        [recommendationsButton addTarget:self action:@selector(recommendTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (cell.connectionsButton.allTargets.count == 0) {
        cell.connectionsButton.userInteractionEnabled = NO;
        //        [connectionsButton addTarget:self action:@selector(connectTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.recommendations.tag = indexPath.row;
    cell.connections.tag = indexPath.row;
}

#pragma mark - Data Mapping

- (void)mapUser:(FIRDataSnapshot *)user toCell:(UserCollectionViewCell *)cell
{
    [cell.userimage setImageWithURL:[NSURL URLWithString:user.value[kProfilePic]]
                   placeholderImage:[UIImage imageNamed:DEFAULT_user]];
    
    cell.username.text = user.value[kDisplayName];
    cell.role.text = user.value[kPrimaryRole];
    
    NSString *location = [NSString stringWithFormat:@"%@, %@", user.value[kCity], user.value[kState]];
    cell.location.text = location;
    
    if (user.value[kReelURL]) {
        [cell.videoPlayerViewController setVideoIdentifier:user.value[kReelURL]];
    } else {
        [cell.videoPlayerViewController setVideoIdentifier:DEFAULT_reel];
    }
    
    NSArray *recommendations = user.value[kRecommendedBy];
    NSString *recString = [NSString stringWithFormat:@"%ld", recommendations.count];
    cell.recommendations.text = recString;
    
    NSArray *connections = user.value[kConnections];
    NSString *conString = [NSString stringWithFormat:@"%ld", connections.count];
    cell.connections.text = conString;
    
    [self mapUserStatus:user toCell:cell];
    
//    NSLog(@"user: %@", user);
}

- (void)mapUserStatus:(FIRDataSnapshot *)user toCell:(UserCollectionViewCell *)cell
{
    NSString *currentUserID = [FIRAuth auth].currentUser.uid;
    
    if ([[user.value[kConnections] allKeys] containsObject:currentUserID]) {
        cell.status.text = [NSString stringWithFormat:@"You are connected!"];
    } else if ([[user.value[kRequestsSent] allKeys] containsObject:currentUserID]) {
        cell.status.text = [NSString stringWithFormat:@"Connection request received!"];
    } else if ([[user.value[kRequestsReceived] allKeys] containsObject:currentUserID]) {
        cell.status.text = [NSString stringWithFormat:@"Connection request awaiting response..."];
    } else {
        NSInteger commonConnections = [[self keysForCommonConnectionsWithUser:user] count];
        if (commonConnections > 0) {
            cell.status.text = [NSString stringWithFormat:@"You share %ld connections", commonConnections];
        } else if ([[user.value[kRecommendedBy] allKeys] containsObject:currentUserID]) {
            cell.status.text = [NSString stringWithFormat:@"You recommend %@!", user.value[kDisplayName]];
        } else {
            cell.status.text = [NSString stringWithFormat:@"Someone new!"];
        }
    }
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    for (UICollectionViewCell *cell in _collectionView.visibleCells) {
        if (CGRectContainsPoint(self.view.frame, [cell.superview convertPoint:cell.center toView:self.view])) {
            if (self.focusedCell != cell && self.focusedCell != nil) {
                
                [self.focusedCell.videoPlayerViewController.moviePlayer stop];
                
                self.focusedCell = (UserCollectionViewCell *)cell;
                
                [self.focusedCell.videoPlayerViewController.moviePlayer play];

            }
        }
    }
}

#pragma mark - MoviePlayer

- (void)MPMoviePlayerPlaybackStateDidChange:(NSNotification *)notification
{
    if (self.focusedCell.videoPlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStatePlaying)
    {
//        NSLog(@"play");
        self.focusedCell.videoContainer.hidden = NO;
    }
    if (self.focusedCell.videoPlayerViewController.moviePlayer.playbackState == MPMoviePlaybackStateStopped)
    {
//        NSLog(@"stop");
        self.focusedCell.videoContainer.hidden = YES;
    }
}

@end

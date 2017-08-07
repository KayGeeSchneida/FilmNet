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

@interface FeedViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UserCollectionViewCell *focusedCell;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (strong, nonatomic) NSMutableDictionary *users;
@property (strong, nonatomic) NSArray *keys;

@end

@implementation FeedViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];

    [self.collectionView registerClass:[UserCollectionViewCell class]
            forCellWithReuseIdentifier:@"UserCollectionViewCell"];
    
    UINib *cellNib = [UINib nibWithNibName:@"UserCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"UserCollectionViewCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(MPMoviePlayerPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:nil];
    
    [self fetchFeed];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:!self.shouldShowNavBar];
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

#pragma mark - Feed Service Call

- (void)fetchFeed {

    self.ref = [[FIRDatabase database] reference];
    
    if (!self.feedReference) {
        self.feedReference = [[FIRDatabase database] referenceWithPath:kUsers];
    }
    
    [self.feedReference observeEventType:FIRDataEventTypeValue
                               withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         self.keys = [snapshot.value allKeys];
         [self.collectionView reloadData];
         
         [self populateFeed];
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

#pragma mark - Data

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
    NSString *recString = [NSString stringWithFormat:@"%ld Recommendations", recommendations.count];
    [cell.recommendations setTitle:recString forState:UIControlStateNormal];
    
    NSArray *connections = user.value[kConnections];
    NSString *conString = [NSString stringWithFormat:@"%ld Connections", connections.count];
    [cell.connections setTitle:conString forState:UIControlStateNormal];
}

#pragma mark - Recommend

- (void)recommendTapped:(id)sender {
    
    NSString *userID = [self.keys objectAtIndex:[sender tag]];
    [RecommendService recommendUserWithID:userID inViewController:self];
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.keys.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserCollectionViewCell *cell = (UserCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"UserCollectionViewCell" forIndexPath:indexPath];
    
    if (cell.recommendations.allTargets.count == 0) {
        [cell.recommendations addTarget:self action:@selector(recommendTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSString *key = [self.keys objectAtIndex:indexPath.row];
    FIRDataSnapshot *user = [self.users valueForKey:key];
    cell.recommendations.tag = indexPath.row;
    
    if (user) {
        [self mapUser:user toCell:cell];
        
        if (!self.focusedCell) {
            self.focusedCell = cell;
            [self.focusedCell.videoPlayerViewController.moviePlayer play];
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    float statusAndTabHeight = 69.0f;
    return CGSizeMake(kDeviceWidth, collectionView.frame.size.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserViewController *vc = [[UserViewController alloc] init];
    vc.userID = [self.keys objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
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

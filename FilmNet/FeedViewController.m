//
//  FeedViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/20/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "FeedViewController.h"
#import "AppDelegate.h"
#import "UserCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"

@interface FeedViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UserCollectionViewCell *focusedCell;

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (strong, nonatomic) NSArray *users;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[UserCollectionViewCell class]
            forCellWithReuseIdentifier:@"UserCollectionViewCell"];
    
    UINib *cellNib = [UINib nibWithNibName:@"UserCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"UserCollectionViewCell"];
    
    [self fetchFeed];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Feed Service Call

- (void)fetchFeed {

    self.ref = [[FIRDatabase database] reference];
    
    FIRDatabaseReference *usersRef = [[FIRDatabase database] referenceWithPath:kUsers];
    
    [usersRef observeEventType:FIRDataEventTypeValue
                  withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         self.users = [snapshot.value allValues];
         [self.collectionView reloadData];
         
//         NSLog(@"users: %@", self.users);

     }];
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.users.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserCollectionViewCell *cell = (UserCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"UserCollectionViewCell" forIndexPath:indexPath];
    
    NSDictionary *user = [self.users objectAtIndex:indexPath.row];
    
    NSString *location = [NSString stringWithFormat:@"%@, %@", user[kCity], user[kState]];
    
    cell.username.text = [user valueForKey:kDisplayName];
    cell.role.text = [user valueForKey:kPrimaryRole];
    cell.location.text = location;
    
    if ([user valueForKey:kProfilePic]) {
        [cell.userimage setImageWithURL:[NSURL URLWithString:[user valueForKey:kProfilePic]]];
    } else {
        [cell.userimage setImage:[UIImage imageNamed:@"defaultuserimage"]];
    }
    
    if ([user valueForKey:kReelURL]) {
        [cell.videoPlayerViewController setVideoIdentifier:[user valueForKey:kReelURL]];
    } else {
        [cell.videoPlayerViewController setVideoIdentifier:@"sAHSpCDPKn4"];
    }
    
    NSLog(@"vid id: %@", cell.videoPlayerViewController.videoIdentifier);
    
    [cell.videoPlayerViewController.moviePlayer stop];
    self.focusedCell.videoContainer.hidden = YES;
    
    if (!self.focusedCell) {
        self.focusedCell = cell;
        [self.focusedCell.videoPlayerViewController.moviePlayer play];
        self.focusedCell.videoContainer.hidden = NO;
    }

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float statusAndTabHeight = 69.0f;
    return CGSizeMake(kDeviceWidth, kDeviceHeight - statusAndTabHeight);
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    for (UICollectionViewCell *cell in _collectionView.visibleCells) {
        if (CGRectContainsPoint(self.view.frame, [cell.superview convertPoint:cell.center toView:self.view])) {
            if (self.focusedCell != cell && self.focusedCell != nil) {
                
                [self.focusedCell.videoPlayerViewController.moviePlayer stop];
                self.focusedCell.videoContainer.hidden = YES;
                
                self.focusedCell = (UserCollectionViewCell *)cell;
                
                [self.focusedCell.videoPlayerViewController.moviePlayer play];
                self.focusedCell.videoContainer.hidden = NO;

            }
        }
    }
}

@end

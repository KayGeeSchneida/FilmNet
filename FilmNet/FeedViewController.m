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

@interface FeedViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

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
    
    FIRDatabaseReference *usersRef = [[FIRDatabase database] referenceWithPath:@"users"];
    
    [usersRef observeEventType:FIRDataEventTypeValue
                  withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         self.users = [snapshot.value allValues];
         [self.collectionView reloadData];
         NSLog(@"users: %@", self.users);
         
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
    
    double val1 = ((double)arc4random() / ARC4RANDOM_MAX);
    double val2 = ((double)arc4random() / ARC4RANDOM_MAX);
    double val3 = ((double)arc4random() / ARC4RANDOM_MAX);
    
    cell.backgroundColor = [UIColor colorWithRed:val1
                                           green:val2
                                            blue:val3
                                           alpha:1.0f];
    
    NSDictionary *user = [self.users objectAtIndex:indexPath.row];
    
    NSString *location = [NSString stringWithFormat:@"%@, %@", user[@"city"], user[@"state"]];
    
    cell.username.text = [user valueForKey:@"displayname"];
    cell.role.text = [user valueForKey:@"primaryrole"];
    cell.location.text = location;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float statusAndTabHeight = 69.0f;
    return CGSizeMake(kDeviceWidth, kDeviceHeight - statusAndTabHeight);
}

@end

//
//  UserCollectionViewCell.h
//  FilmNet
//
//  Created by Keith Schneider on 7/20/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import <XCDYouTubeKit/XCDYouTubeKit.h>

@interface UserCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *username;
@property (nonatomic, weak) IBOutlet UILabel *role;
@property (nonatomic, weak) IBOutlet UILabel *location;
@property (nonatomic, weak) IBOutlet UIView *card;
@property (nonatomic, weak) IBOutlet UIImageView *userimage;
@property (nonatomic, weak) IBOutlet UIImageView *reelimage;
@property (nonatomic, weak) IBOutlet UIView *videoContainer;
@property (nonatomic, weak) IBOutlet UIButton *connections;
@property (nonatomic, weak) IBOutlet UIButton *recommendations;

@property(nonatomic, strong) XCDYouTubeVideoPlayerViewController *videoPlayerViewController;

@end

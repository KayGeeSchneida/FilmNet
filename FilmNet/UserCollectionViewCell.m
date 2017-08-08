//
//  UserCollectionViewCell.m
//  FilmNet
//
//  Created by Keith Schneider on 7/20/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "UserCollectionViewCell.h"
#import "Constants.h"

@implementation UserCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.username.font = [UIFont fontWithName:FONT_ApercuProBold size:20.0f];
    self.role.font = [UIFont fontWithName:FONT_ApercuProBold size:15.0f];
    self.location.font = [UIFont fontWithName:FONT_ApercuProBold size:15.0f];
    
    self.connectionsButton.titleLabel.font = [UIFont fontWithName:FONT_ApercuPro size:15.0f];
    self.recommendationsButton.titleLabel.font = [UIFont fontWithName:FONT_ApercuPro size:15.0f];
    
    self.connections.font = [UIFont fontWithName:FONT_GraphikStencilXQ size:70.0f];
    self.recommendations.font = [UIFont fontWithName:FONT_GraphikStencilXQ size:70.0f];
    
    self.status.font = [UIFont fontWithName:FONT_ApercuPro size:14.0f];
    
    self.card.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.card.layer.borderWidth = 1.0f;
    
    [self.userimage setImage:[UIImage imageNamed:DEFAULT_user]];
    self.userimage.layer.cornerRadius = self.userimage.frame.size.width/2;
    self.userimage.clipsToBounds = YES;
    
    self.videoPlayerViewController = [[XCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:nil];
    [self.videoPlayerViewController presentInView:self.videoContainer];
}

@end

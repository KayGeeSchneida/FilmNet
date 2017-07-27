//
//  UserCollectionViewCell.m
//  FilmNet
//
//  Created by Keith Schneider on 7/20/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "UserCollectionViewCell.h"

@implementation UserCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.card.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.card.layer.borderWidth = 1.0f;
    
    [self.userimage setImage:[UIImage imageNamed:@"defaultuserimage"]];
    self.userimage.layer.cornerRadius = self.userimage.frame.size.width/2;
    self.userimage.clipsToBounds = YES;
    
    [self.reelimage setImage:[UIImage imageNamed:@"defaultreelimage"]];
    self.reelimage.clipsToBounds = YES;
    self.reelimage.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.reelimage.layer.borderWidth = 1.0f;
}

@end

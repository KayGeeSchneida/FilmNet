//
//  UserCollectionViewCell.h
//  FilmNet
//
//  Created by Keith Schneider on 7/20/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UILabel *username;
@property (nonatomic, weak) IBOutlet UILabel *role;
@property (nonatomic, weak) IBOutlet UILabel *location;
@end

//
//  FNButton.h
//  FilmNet
//
//  Created by Keith Schneider on 8/12/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    FNButtonStyleWhite,
    FNButtonStyleWhiteBordered,
    FNButtonStyleGreen,
    FNButtonStyleDark
} FNButtonStyle;

@interface FNButton : UIButton

@property (nonatomic, assign) FNButtonStyle fnButtonStyle;

@end

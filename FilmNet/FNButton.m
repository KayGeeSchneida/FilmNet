//
//  FNButton.m
//  FilmNet
//
//  Created by Keith Schneider on 8/12/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "FNButton.h"
#import "Constants.h"

@implementation FNButton

- (void)setFnButtonStyle:(FNButtonStyle)fnButtonStyle {
    
    switch (fnButtonStyle) {
        case FNButtonStyleDark:
            self.backgroundColor = COLOR_DarkGray;
            self.layer.borderColor = [UIColor clearColor].CGColor;
            self.layer.borderWidth = 0.0f;
            [self setTitleColor:COLOR_AlmostWhite forState:UIControlStateNormal];
            [self setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateDisabled];
            self.titleLabel.font = [UIFont fontWithName:FONT_ApercuProBold size:15];
            break;
        case FNButtonStyleGreen:
            self.backgroundColor = COLOR_Green;
            self.layer.borderColor = [UIColor clearColor].CGColor;
            self.layer.borderWidth = 0.0f;
            [self setTitleColor:COLOR_AlmostWhite forState:UIControlStateNormal];
            [self setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateDisabled];
            self.titleLabel.font = [UIFont fontWithName:FONT_ApercuProBold size:15];
            break;
        case FNButtonStyleWhite:
            self.backgroundColor = COLOR_AlmostWhite;
            self.layer.borderColor = [UIColor clearColor].CGColor;
            self.layer.borderWidth = 0.0f;
            [self setTitleColor:COLOR_DarkGray forState:UIControlStateNormal];
            [self setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateDisabled];
            self.titleLabel.font = [UIFont fontWithName:FONT_ApercuProBold size:15];
            break;
        case FNButtonStyleWhiteBordered:
            self.backgroundColor = COLOR_AlmostWhite;
            self.layer.borderColor = COLOR_DarkGray.CGColor;
            self.layer.borderWidth = 1.0f;
            [self setTitleColor:COLOR_DarkGray forState:UIControlStateNormal];
            [self setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateDisabled];
            self.titleLabel.font = [UIFont fontWithName:FONT_ApercuProBold size:15];
            break;
        default:
            break;
    }
}

@end

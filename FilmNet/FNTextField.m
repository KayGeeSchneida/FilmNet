//
//  FNTextField.m
//  FilmNet
//
//  Created by Keith Schneider on 8/12/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "FNTextField.h"
#import "Constants.h"

@implementation FNTextField

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textAlignment = NSTextAlignmentCenter;
    self.font = [UIFont fontWithName:FONT_ApercuPro size:15];
    self.textColor = COLOR_DarkGray;
    self.borderStyle = UITextBorderStyleNone;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1)];
    line.backgroundColor = COLOR_DarkGray;
    [self addSubview:line];
}

@end

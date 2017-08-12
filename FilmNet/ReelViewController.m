//
//  ReelViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 8/3/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "ReelViewController.h"
#import "AppDelegate.h"

@interface ReelViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *reelLabel;
@property (nonatomic, weak) IBOutlet UITextView *stepsView;

@end

@implementation ReelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reelLabel.font = [UIFont fontWithName:FONT_GraphikStencilXQ size:30];
    self.stepsView.font = [UIFont fontWithName:FONT_ApercuPro size:12];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];

    NSString *ytID = [self extractYoutubeIdFromLink:textField.text];
    
    [[[[ref child:kUsers] child:[FIRAuth auth].currentUser.uid] child:kReelURL] setValue:ytID];

    [self.navigationController popViewControllerAnimated:YES];
    
    return YES;
}

- (NSString *)extractYoutubeIdFromLink:(NSString *)link {
    NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    
    NSArray *array = [regExp matchesInString:link options:0 range:NSMakeRange(0,link.length)];
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        return [link substringWithRange:result.range];
    }
    return nil;
}

@end

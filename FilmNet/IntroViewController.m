//
//  IntroViewController.m
//  FilmNet
//
//  Created by Keith Schneider on 7/19/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "IntroViewController.h"
#import "AppDelegate.h"

#import "SignupViewController.h"
#import "LoginViewController.h"
#import "FNButton.h"

@interface IntroViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *slidesScrollView;
@property (nonatomic, weak) IBOutlet UILabel *filmnetLabel;
@property (nonatomic, weak) IBOutlet UILabel *sloganLabel;
@property (nonatomic, weak) IBOutlet FNButton *loginButton;
@property (nonatomic, weak) IBOutlet FNButton *signupButton;

@property (nonatomic, assign) int slidesCount;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation IntroViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.slidesCount = 3;
    
    [self additionalSetup];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupSlidesScrollView];
    
    [self checkUserAuthenticated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View Setup

- (void)additionalSetup {
    self.filmnetLabel.font = [UIFont fontWithName:FONT_GraphikStencilXQ size:40];
    self.sloganLabel.font = [UIFont fontWithName:FONT_ApercuProBold size:20];
    
    [self.signupButton setFnButtonStyle:FNButtonStyleGreen];
    [self.loginButton setFnButtonStyle:FNButtonStyleWhiteBordered];
}

#pragma mark - Slides

- (void)setupSlidesScrollView {
    [self addSlides];
    
    self.slidesScrollView.contentSize = CGSizeMake(_slidesCount*self.slidesScrollView.frame.size.width,
                                                   self.slidesScrollView.frame.size.height);
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(scrollSlide) userInfo:nil repeats:YES];
    }
}

- (void)addSlides {
    
    for (int i = 0; i < self.slidesCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.slidesScrollView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"slide-%d",i]]];
        CGRect frame = imageView.frame;
        frame.origin.x = i*frame.size.width;
        imageView.frame = frame;
        [self.slidesScrollView addSubview:imageView];
    }
    
}

- (void)scrollSlide {
    
    CGPoint newOffset = self.slidesScrollView.contentOffset;
    newOffset.x += self.slidesScrollView.frame.size.width;
    
    if (newOffset.x >= self.slidesScrollView.contentSize.width) {
        newOffset.x = 0;
    }
    
    [self.slidesScrollView setContentOffset:newOffset animated:YES];
}

#pragma mark - Navigation

- (IBAction)tappedLogin:(id)sender {
    LoginViewController *vc = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)tappedSignup:(id)sender {
    SignupViewController *vc = [[SignupViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)presentHome {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITableViewController *tvc = [sb instantiateViewControllerWithIdentifier:@"MainTabViewController"];
    tvc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:tvc animated:YES completion:NULL];
}

#pragma mark - Authentication

- (void)checkUserAuthenticated {
    
    if ([FIRAuth auth].currentUser) {
        
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        [[[[[FIRDatabase database] reference] child:kUsers] child:userID] observeSingleEventOfType:FIRDataEventTypeValue
                                                           withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
         {
             if ([snapshot hasChildren] &&
                 [snapshot.value[kUserEmail] length] > 0) {
                 [self presentHome];
             } else {
                 // No valid user
             }
             
         } withCancelBlock:^(NSError * _Nonnull error) {
             NSLog(@"%@", error.localizedDescription);
         }];
    }
}

@end

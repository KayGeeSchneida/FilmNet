//
//  RecommendService.m
//  FilmNet
//
//  Created by Keith Schneider on 8/7/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "RecommendService.h"

@implementation RecommendService

+ (void)recommendUserWithID:(NSString *)userID inViewController:(UIViewController *)vc {
    
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];

    NSString *currentUserID = [FIRAuth auth].currentUser.uid;

    [[[[ref child:kUsers] child:currentUserID] child:kRecommendations] observeSingleEventOfType:FIRDataEventTypeValue
                                                       withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
    {
        if ([snapshot hasChild:userID]) {
            // Already recommended
            [self showAlertUserAlreadyRecommendUserWithID:userID inViewController:vc];
        } else {
            // Time to recommend
            [self showAlertToRecommendUserWithID:userID inViewController:vc];
        }
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

+ (void)showAlertUserAlreadyRecommendUserWithID:(NSString *)userID inViewController:(UIViewController *)vc {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Recommended"
                                message:@"You have already recommended this user!"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:@"OK!"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {

                                }];
    
    [alert addAction:yesButton];
    
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)showAlertToRecommendUserWithID:(NSString *)userID inViewController:(UIViewController *)vc {

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Recommend User?"
                                message:@"Do you wish to recommend this user to others?"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:@"Absolutely!"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    [RecommendService sendRecommendForUserWithID:userID];
                                }];
    
    [alert addAction:yesButton];
    
    UIAlertAction *noButton = [UIAlertAction
                               actionWithTitle:@"Let me think about it..."
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {
                                   
                               }];
    
    [alert addAction:noButton];
    
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)sendRecommendForUserWithID:(NSString *)userID
{
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];

    NSString *currentUserID = [FIRAuth auth].currentUser.uid;

    [[[[[ref child:kUsers] child:currentUserID] child:kRecommendations] child:userID] setValue:@YES];
    [[[[[ref child:kUsers] child:userID] child:kRecommendedBy] child:currentUserID] setValue:@YES];
}

+ (FIRDatabaseReference *)feedReferenceForCurrentUserRecommenders
{
    NSString *userID = [FIRAuth auth].currentUser.uid;
    return [RecommendService feedReferenceForUserRecommenders:userID];
}

+ (FIRDatabaseReference *)feedReferenceForUserRecommenders:(NSString *)userID
{
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",kUsers,userID,kRecommendedBy];
    return [[FIRDatabase database] referenceWithPath:path];
}

@end

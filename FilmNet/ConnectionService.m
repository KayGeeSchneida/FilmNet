//
//  ConnectionService.m
//  FilmNet
//
//  Created by Keith Schneider on 8/7/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "ConnectionService.h"

@implementation ConnectionService

+ (void)connectToUserWithID:(NSString *)userID inViewController:(UIViewController *)vc {

    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    
    NSString *currentUserID = [FIRAuth auth].currentUser.uid;
    
    [[[[ref child:kUsers] child:currentUserID] child:kConnections] observeSingleEventOfType:FIRDataEventTypeValue
                                                                                      withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
     {
         if ([snapshot hasChild:userID]) {
             // Already connected
             [self showAlertUserAlreadyConnectedToUserWithID:userID inViewController:vc];
             
         } else {
             
             [[[[ref child:kUsers] child:currentUserID] child:kRequestsSent] observeSingleEventOfType:FIRDataEventTypeValue
                                                                                           withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
              {
                  if ([snapshot hasChild:userID]) {
                      // Already sent
                      [self showAlertUserAlreadySentRequestToUserWithID:userID inViewController:vc];
                  } else {
                      
                      
                      [[[[ref child:kUsers] child:currentUserID] child:kRequestsReceived] observeSingleEventOfType:FIRDataEventTypeValue
                                                                                                     withBlock:^(FIRDataSnapshot * _Nonnull snapshot)
                       {
                           if ([snapshot hasChild:userID]) {
                               // Accept request
                               [self showAlertToAcceptRequestToUserWithID:userID inViewController:vc];
                           } else {
                               // Send request
                               [self showAlertToSendRequestToUserWithID:userID inViewController:vc];
                           }
                           
                       } withCancelBlock:^(NSError * _Nonnull error) {
                           NSLog(@"%@", error.localizedDescription);
                       }];
                  }
                  
              } withCancelBlock:^(NSError * _Nonnull error) {
                  NSLog(@"%@", error.localizedDescription);
              }];
         }
         
     } withCancelBlock:^(NSError * _Nonnull error) {
         NSLog(@"%@", error.localizedDescription);
     }];
}


+ (void)showAlertUserAlreadyConnectedToUserWithID:(NSString *)userID inViewController:(UIViewController *)vc {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Connected"
                                message:@"You have already connected with this user!"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:@"OK!"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    
                                }];
    
    [alert addAction:yesButton];
    
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)showAlertUserAlreadySentRequestToUserWithID:(NSString *)userID inViewController:(UIViewController *)vc {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Request Pending"
                                message:@"Your connection request is still awaiting response!"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:@"OK!"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    
                                }];
    
    [alert addAction:yesButton];
    
    [vc presentViewController:alert animated:YES completion:nil];
}

+ (void)showAlertToSendRequestToUserWithID:(NSString *)userID inViewController:(UIViewController *)vc {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Connect With User?"
                                message:@"Do you wish to send a connection request?"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:@"Absolutely!"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    [ConnectionService requestConnectionToUserWithID:userID];
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

+ (void)showAlertToAcceptRequestToUserWithID:(NSString *)userID inViewController:(UIViewController *)vc {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Connect With User?"
                                message:@"Do you wish to accept this user's connection request?"
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:@"Absolutely!"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    [ConnectionService acceptConnectionToUserWithID:userID];
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

+ (void)requestConnectionToUserWithID:(NSString *)userID
{
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    
    NSString *currentUserID = [FIRAuth auth].currentUser.uid;
    
    [[[[[ref child:kUsers] child:currentUserID] child:kRequestsSent] child:userID] setValue:@YES];
    [[[[[ref child:kUsers] child:userID] child:kRequestsReceived] child:currentUserID] setValue:@YES];
}

+ (void)acceptConnectionToUserWithID:(NSString *)userID
{
    FIRDatabaseReference *ref = [[FIRDatabase database] reference];
    
    NSString *currentUserID = [FIRAuth auth].currentUser.uid;
    
    [[[[[ref child:kUsers] child:currentUserID] child:kConnections] child:userID] setValue:@YES];
    [[[[[ref child:kUsers] child:userID] child:kConnections] child:currentUserID] setValue:@YES];
}

+ (FIRDatabaseReference *)feedReferenceForCurrentUserConnections
{
    NSString *userID = [FIRAuth auth].currentUser.uid;
    return [ConnectionService feedReferenceForUserConnections:userID];
}

+ (FIRDatabaseReference *)feedReferenceForUserConnections:(NSString *)userID
{
    NSString *path = [NSString stringWithFormat:@"%@/%@/%@",kUsers,userID,kConnections];
    return [[FIRDatabase database] referenceWithPath:path];
}

@end

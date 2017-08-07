//
//  ConnectionService.h
//  FilmNet
//
//  Created by Keith Schneider on 8/7/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface ConnectionService : NSObject

+ (void)connectToUserWithID:(NSString *)userID inViewController:(UIViewController *)vc;

@end

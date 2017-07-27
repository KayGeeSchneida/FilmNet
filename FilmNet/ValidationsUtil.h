//
//  ValidationsUtil.h
//  FilmNet
//
//  Created by Keith Schneider on 7/27/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValidationsUtil : NSObject

+ (BOOL)validateEmail:(NSString *)email;
+ (BOOL)validateZip:(NSString *)zip;

@end

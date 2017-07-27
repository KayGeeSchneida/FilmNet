//
//  ValidationsUtil.m
//  FilmNet
//
//  Created by Keith Schneider on 7/27/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#import "ValidationsUtil.h"

@implementation ValidationsUtil

+ (BOOL)validateEmail:(NSString *)email
{
    if ([email length] == 0) {
        return NO;
    }
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
}

+ (BOOL)validateZip:(NSString *)zip
{
    if ([zip length] == 0) {
        return NO;
    }
    
    NSString *postcodeRegex = @"^(\\d{5}(-\\d{4})?|[a-z]\\d[a-z][- ]*\\d[a-z]\\d)$";
    NSPredicate *postcodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", postcodeRegex];
    BOOL isValid = [postcodeTest evaluateWithObject:zip];
    return isValid;
}

@end

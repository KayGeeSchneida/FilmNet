//
//  Constants.h
//  FilmNet
//
//  Created by Keith Schneider on 7/27/17.
//  Copyright © 2017 Thought Foundry. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define ARC4RANDOM_MAX      0x100000000

#define kDeviceWidth    [[UIScreen mainScreen] bounds].size.width
#define kDeviceHeight   [[UIScreen mainScreen] bounds].size.height
#define kStatusHeight   [UIApplication sharedApplication].statusBarFrame.size.height

#define ROLES @[@"Producer",@"Director",@"Screenwriter",@"Production Designer",@"Art Director",@"Costume Designer",@"Cinematographer",@"Editor",@"Actor",@"Music Supervisor",@"Script Supervisor",@"Make-Up Artist",@"Sound Designer",@"Location Sound",@"Production Assistant"]

#define kUsers          @"users"

#define kCity           @"city"
#define kState          @"state"
#define kCountry        @"country"
#define kZipcode        @"zipcode"

#define kUserEmail      @"useremail"
#define kDisplayName    @"displayname"
#define kPrimaryRole    @"primaryrole"
#define kUserDetails    @"userdetails"

#endif /* Constants_h */

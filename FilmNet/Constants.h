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

#define FONT_ApercuPro          @"ApercuPro"
#define FONT_ApercuProBold      @"ApercuPro-Bold"
#define FONT_GraphikStencilXQ   @"Graphik-StencilXQ-Regular"

#define kDeviceWidth    [[UIScreen mainScreen] bounds].size.width
#define kDeviceHeight   [[UIScreen mainScreen] bounds].size.height
#define kStatusHeight   [UIApplication sharedApplication].statusBarFrame.size.height

#define ROLES @[@"Producer",@"Director",@"Screenwriter",@"Production Designer",@"Art Director",@"Costume Designer",@"Cinematographer",@"Editor",@"Actor",@"Music Supervisor",@"Script Supervisor",@"Make-Up Artist",@"Sound Designer",@"Location Sound",@"Production Assistant"]

#define DEFAULT_reel    @"sAHSpCDPKn4"
#define DEFAULT_user    @"defaultuserimage"

#define kUsers          @"users"

#define kCity           @"city"
#define kState          @"state"
#define kCountry        @"country"
#define kZipcode        @"zipcode"

#define kUserEmail      @"useremail"
#define kDisplayName    @"displayname"
#define kPrimaryRole    @"primaryrole"
#define kUserDetails    @"userdetails"
#define kProfilePic     @"profilepic"
#define kReelURL        @"reelurl"

#define kRequestsSent       @"requestssent"
#define kRequestsReceived   @"requestsreceived"
#define kConnections        @"connections"
#define kConnectionCount    @"connectioncount"

#define kRecommendations    @"recommendations"
#define kRecommendedBy      @"recommendedby"
#define kRecommendedCount   @"recommendedcount"

#define kAlertOK            @"Got it!"
#define kAlertYes           @"Absolutely!"
#define kAlertNo            @"Let me think about it..."

#define COLOR_Green         [UIColor colorWithRed:(90.0/255.0) green:(196.0/255.0) blue:(107.0/255.0) alpha:1.0]
#define COLOR_DarkGray      [UIColor colorWithWhite:0.11 alpha:1.00]
#define COLOR_AlmostWhite   [UIColor colorWithWhite:0.95 alpha:1.00]

#endif /* Constants_h */

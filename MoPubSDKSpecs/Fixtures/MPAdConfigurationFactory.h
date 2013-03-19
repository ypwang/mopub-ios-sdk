//
//  MPAdConfigurationFactory.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdConfiguration.h"

@interface MPAdConfigurationFactory : NSObject

+ (MPAdConfiguration *)defaultBannerConfiguration;
+ (MPAdConfiguration *)defaultInterstitialConfiguration;
+ (MPAdConfiguration *)defaultBannerConfigurationWithHeaders:(NSDictionary *)dictionary
                                                  HTMLString:(NSString *)HTMLString;

@end

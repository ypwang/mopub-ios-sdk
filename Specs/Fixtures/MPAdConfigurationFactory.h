//
//  MPAdConfigurationFactory.h
//  MoPubSDK
//
//  Created by pivotal on 3/14/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdConfiguration.h"

@interface MPAdConfigurationFactory : NSObject

+ (MPAdConfiguration *)defaultBannerConfiguration;
+ (MPAdConfiguration *)defaultBannerConfigurationWithHeaders:(NSDictionary *)dictionary
                                                  HTMLString:(NSString *)HTMLString;

@end

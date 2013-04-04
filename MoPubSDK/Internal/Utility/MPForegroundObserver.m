//
//  MPForegroundObserver.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPForegroundObserver.h"
#import "MPConstants.h"
#import "MPIdentityProvider.h"
#import "MPGlobal.h"
#import "MPInstanceProvider.h"

@implementation MPForegroundObserver

+ (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(trackEvent)
                                                name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(trackEvent)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
}

+ (void)trackEvent
{
    [NSURLConnection connectionWithRequest:[[MPInstanceProvider sharedProvider] buildConfiguredURLRequestWithURL:[self URL]]
                                  delegate:nil];

}

+ (NSURL *)URL
{
    NSString *path = [NSString stringWithFormat:@"http://%@/m/open?v=%@&udid=%@&id=%@&av=%@",
                      HOSTNAME,
                      MP_SERVER_VERSION,
                      [MPIdentityProvider identifier],
                      [[[NSBundle mainBundle] bundleIdentifier] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                      [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                      ];

    return [NSURL URLWithString:path];
}

@end

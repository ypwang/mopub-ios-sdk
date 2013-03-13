//
//  UIApplication+MPSpecs.m
//  MoPubSDK
//
//  Created by pivotal on 3/13/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UIApplication+MPSpecs.h"
#import "objc/runtime.h"

static char LAST_OPENED_URL_KEY;

@implementation UIApplication (MPSpecs)

+ (void)beforeEach
{
    [[UIApplication sharedApplication] setLastOpenedURL:nil];
}

- (NSURL *)lastOpenedURL
{
    return objc_getAssociatedObject(self, &LAST_OPENED_URL_KEY);
}

- (void)setLastOpenedURL:(NSURL *)url
{
    objc_setAssociatedObject(self, &LAST_OPENED_URL_KEY, url, OBJC_ASSOCIATION_RETAIN);
}

- (void)openURL:(NSURL *)url
{
    self.lastOpenedURL = url;
}

@end

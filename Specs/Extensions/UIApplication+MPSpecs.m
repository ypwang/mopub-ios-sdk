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
static char STATUS_BAR_ORIENTATION;

@implementation UIApplication (MPSpecs)

+ (void)beforeEach
{
    [[UIApplication sharedApplication] setLastOpenedURL:nil];
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
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

- (void)setStatusBarOrientation:(UIInterfaceOrientation)orientation
{
    objc_setAssociatedObject(self, &STATUS_BAR_ORIENTATION, [NSNumber numberWithInteger:orientation], OBJC_ASSOCIATION_RETAIN);
}

- (UIInterfaceOrientation)statusBarOrientation
{
    return [objc_getAssociatedObject(self, &STATUS_BAR_ORIENTATION) integerValue];
}

@end

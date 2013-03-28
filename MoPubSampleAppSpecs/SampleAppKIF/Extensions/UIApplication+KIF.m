//
//  UIApplication+KIF.m
//  MoPubSampleApp
//
//  Created by pivotal on 3/28/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "UIApplication+KIF.h"

@implementation UIApplication (KIF)

- (void)openURL:(NSURL *)url
{
    NSLog(@"================> Application tried to open: %@", url);
}

@end

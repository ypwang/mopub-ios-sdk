//
//  UIApplication+MPSpecs.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (MPSpecs)

- (NSURL *)lastOpenedURL;
- (void)setStatusBarOrientation:(UIInterfaceOrientation)orientation;

@end

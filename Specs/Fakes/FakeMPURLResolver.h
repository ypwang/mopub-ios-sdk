//
//  FakeMPURLResolver.h
//  MoPubSDK
//
//  Created by pivotal on 3/13/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPURLResolver.h"

@interface FakeMPURLResolver : MPURLResolver

@property (nonatomic, assign) NSURL *URL;
@property (nonatomic, assign) BOOL didCancel;

@end

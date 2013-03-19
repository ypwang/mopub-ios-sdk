//
//  FakeMPInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"

@interface FakeMPInstanceProvider : MPInstanceProvider

@property (nonatomic, assign) MPAdWebViewAgent *fakeMPAdWebViewAgent;
@property (nonatomic, assign) MPAdWebView *fakeMPAdWebView;
@property (nonatomic, assign) MPAdDestinationDisplayAgent *fakeMPAdDestinationDisplayAgent;
@property (nonatomic, assign) MPURLResolver *fakeMPURLResolver;

@end

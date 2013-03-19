//
//  MPSampleAppInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPAdView;

@interface MPSampleAppInstanceProvider : NSObject

+ (MPSampleAppInstanceProvider *)sharedProvider;
- (MPAdView *)buildMPAdViewWithAdUnitID:(NSString *)ID size:(CGSize)size;

@end

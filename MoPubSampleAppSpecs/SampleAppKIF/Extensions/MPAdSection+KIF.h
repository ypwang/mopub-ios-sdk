//
//  MPAdSection+KIF.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdSection.h"

@interface MPAdSection (KIF)

+ (NSIndexPath *)indexPathForAd:(NSString *)adTitle inSection:(NSString *)sectionTitle;

@end

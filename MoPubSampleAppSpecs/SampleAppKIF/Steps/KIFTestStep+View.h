//
//  KIFTestStep+View.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep.h"

@interface KIFTestStep (View)

+ (KIFTestStep *)stepToWaitForPresenceOfViewWithClassName:(NSString *)className;
+ (KIFTestStep *)stepToWaitForAbsenseOfViewWithClassName:(NSString *)className;

@end

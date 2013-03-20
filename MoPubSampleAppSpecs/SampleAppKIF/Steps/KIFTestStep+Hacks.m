//
//  KIFTestStep+Hacks.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestStep+Hacks.h"

@implementation KIFTestStep (Hacks)

+ (KIFTestStep *)stepToPerformBlock:(KIFTestStepBlock)block {
    return [KIFTestStep stepWithDescription:@"Perform block" executionBlock:^KIFTestStepResult(KIFTestStep *step, NSError *__autoreleasing *error) {

        block();

        return KIFTestStepResultSuccess;
    }];
}

@end

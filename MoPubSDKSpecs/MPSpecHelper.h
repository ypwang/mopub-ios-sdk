//
//  MPSpecHelper.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Foundation+PivotalSpecHelper.h"
#import "UIKit+PivotalSpecHelper.h"
#import "NSURLConnection+MPSpecs.h"
#import "UIApplication+MPSpecs.h"
#import "MPStoreKitProvider+MPSpecs.h"
#import "FakeMPInstanceProvider.h"
#import "NSErrorFactory.h"
#import "InterstitialIntegrationSharedBehaviors.h"

@protocol CedarDouble;

typedef void (^NoArgBlock)();
typedef id (^IDReturningBlock)();

void verify_fake_received_selectors(id<CedarDouble> fake, NSArray *selectors);

extern FakeMPInstanceProvider *fakeProvider;

@interface MPSpecHelper : NSObject

@end

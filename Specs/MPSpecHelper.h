//
//  MPSpecHelper.h
//  MoPubSDK
//
//  Created by pivotal on 3/12/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Foundation+PivotalSpecHelper.h"
#import "UIKit+PivotalSpecHelper.h"
#import "NSURLConnection+MPSpecs.h"
#import "UIApplication+MPSpecs.h"
#import "MPStoreKitProvider+MPSpecs.h"
#import "FakeMPInstanceProvider.h"

typedef void (^NoArgBlock)();
typedef id (^IDReturningBlock)();

extern FakeMPInstanceProvider *fakeProvider;

@interface MPSpecHelper : NSObject

@end

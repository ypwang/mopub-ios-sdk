//
//  NSURLConnection+MPSpecs.h
//  MoPubSDK
//
//  Created by pivotal on 3/12/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLConnection (MPSpecs)

+ (NSURLConnection *)lastConnection;
- (void)receiveSuccessfulResponse:(NSString *)body;

@end

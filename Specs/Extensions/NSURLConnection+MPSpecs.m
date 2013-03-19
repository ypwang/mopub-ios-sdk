//
//  NSURLConnection+MPSpecs.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "NSURLConnection+MPSpecs.h"

@implementation NSURLConnection (MPSpecs)

+ (NSURLConnection *)lastConnection
{
    return [[NSURLConnection connections] lastObject];
}

- (void)receiveSuccessfulResponse:(NSString *)body
{
    PSHKFakeHTTPURLResponse *response = [[[PSHKFakeHTTPURLResponse alloc] initWithStatusCode:200
                                                                                  andHeaders:nil
                                                                                     andBody:body] autorelease];
    [self receiveResponse:response];
}

@end

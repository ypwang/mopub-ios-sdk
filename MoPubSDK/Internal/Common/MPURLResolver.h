//
//  MPURLResolver.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MPURLResolverDelegate;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_5_0
@interface MPURLResolver : NSObject <NSURLConnectionDataDelegate>
#else
@interface MPURLResolver : NSObject
#endif

+ (MPURLResolver *)resolverWithURL:(NSURL *)URL delegate:(id<MPURLResolverDelegate>)delegate;

@end

@protocol MPURLResolverDelegate <NSObject>

- (void)showWebViewWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)URL;
- (void)showStoreKitProductWithParameter:(NSString *)parameter fallbackURL:(NSURL *)URL;
- (void)openURLInApplication:(NSURL *)URL;
- (void)failedToResolveURLWithError:(NSError *)error;

@end

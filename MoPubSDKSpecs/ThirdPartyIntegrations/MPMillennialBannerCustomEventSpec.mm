#import "MPMillennialBannerCustomEvent.h"
#import "FakeMMBannerAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPMillennialBannerCustomEventSpec)

describe(@"MPMillennialBannerCustomEvent", ^{
    __block id<CedarDouble, MPBannerCustomEventDelegate> delegate;
    __block MPMillennialBannerCustomEvent *event;
    __block FakeMMBannerAdView *banner;
    __block CLLocation *location;
    __block NSDictionary *customEventInfo;
    __block UIViewController *viewController;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBannerCustomEventDelegate));
        
        banner = [[[FakeMMBannerAdView alloc] init] autorelease];
        fakeProvider.fakeMMAdViewBanner = banner;
        
        event = [[[MPMillennialBannerCustomEvent alloc] init] autorelease];
        event.delegate = delegate;
        
        location = [[[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(37.1, 21.2)
                                                  altitude:11
                                        horizontalAccuracy:12.3
                                          verticalAccuracy:10
                                                 timestamp:[NSDate date]] autorelease];
        delegate stub_method("location").and_return(location);
        
        viewController = [[[UIViewController alloc] init] autorelease];
        delegate stub_method("viewControllerForPresentingModalView").and_return(viewController);

        customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@728, @"adHeight":@90};
    });
    
    subjectAction(^{
        [event requestAdWithSize:CGSizeZero customEventInfo:customEventInfo];
    });
    
    it(@"should allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(YES);
    });
    
    context(@"when asked to fetch a banner", ^{
        it(@"should set the banner's ad unit ID and delegate", ^{
            banner.apid should equal(@"mmmmmmm");
            banner.delegate should equal(event);
            banner.rootViewController should equal(viewController);
            banner.hasRefreshed should equal(YES);
        });
        
        context(@"the banner size", ^{
            context(@"when the banner size matches the regular banner size", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@320, @"adHeight":@53};
                });
                
                it(@"should fetch a banner of the right size and type", ^{
                    CGRectEqualToRect(banner.frame, CGRectMake(0, 0, 320, 53)) should equal(YES);
                    banner.type should equal(MMBannerAdTop);
                });
            });
            
            context(@"when the banner size matches the leaderboard banner size", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@728, @"adHeight":@90};
                });
                
                it(@"should fetch a banner of the right size and type", ^{
                    CGRectEqualToRect(banner.frame, CGRectMake(0, 0, 728, 90)) should equal(YES);
                    banner.type should equal(MMBannerAdTop);
                });
            });
            
            context(@"when the banner size matches the rectangle size", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@300, @"adHeight":@250};
                });
                
                it(@"should fetch a banner of the right size and type", ^{
                    CGRectEqualToRect(banner.frame, CGRectMake(0, 0, 300, 250)) should equal(YES);
                    banner.type should equal(MMBannerAdRectangle);
                });
            });
            
            context(@"when the size doesn't match one of the above", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm", @"adWidth":@370, @"adHeight":@250};
                });
                
                it(@"should fetch a banner of the 320x53 size and top type", ^{
                    CGRectEqualToRect(banner.frame, CGRectMake(0, 0, 320, 53)) should equal(YES);
                    banner.type should equal(MMBannerAdTop);
                });
            });
            
            context(@"when the size is not present", ^{
                beforeEach(^{
                    customEventInfo = @{@"adUnitID": @"mmmmmmm"};
                });
                
                it(@"should fetch a banner of the 320x53 size and top type", ^{
                    CGRectEqualToRect(banner.frame, CGRectMake(0, 0, 320, 53)) should equal(YES);
                    banner.type should equal(MMBannerAdTop);
                });
            });
        });
    });
    
    describe(@"requestData", ^{
        it(@"should have the vendor", ^{
            [event requestData][@"vendor"] should equal(@"mopubsdk");
        });
        
        it(@"should have the lat/long", ^{
            [event requestData][@"lat"] should equal(@"37.1");
            [event requestData][@"long"] should equal(@"21.2");
        });
    });
});

SPEC_END

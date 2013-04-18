#import "MPMillennialInterstitialCustomEvent.h"
#import "FakeMMInterstitialAdView.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPInstanceProvider (MillennialInterstitialsSpec)

- (MMAdView *)buildMMInterstitialAdWithAPID:(NSString *)apid delegate:(id<MMAdDelegate>)delegate;

@end

SPEC_BEGIN(MPMillennialInterstitialCustomEventSpec)

describe(@"MPMillennialInterstitialAdapter MPInstanceProvider additions", ^{
    __block MPMillennialInterstitialCustomEvent<CedarDouble> *fakeEvent;
    __block MPInstanceProvider *provider;
    
    beforeEach(^{
        fakeEvent = nice_fake_for([MPMillennialInterstitialCustomEvent class]);
        provider = [[[MPInstanceProvider alloc] init] autorelease];
    });
    
    it(@"should return a correctly configured ad view", ^{
        MMAdView *adView = [provider buildMMInterstitialAdWithAPID:@"foo" delegate:fakeEvent];
        adView.delegate should equal(fakeEvent);
    });
    
    it(@"should return a shared instance for each apid", ^{
        MMAdView *fooAdView = [provider buildMMInterstitialAdWithAPID:@"foo" delegate:fakeEvent];
        fooAdView.delegate should equal(fakeEvent);
        
        MPMillennialInterstitialCustomEvent<CedarDouble> *newFakeEvent = nice_fake_for([MPMillennialInterstitialCustomEvent class]);
        MMAdView *newFooAdView = [provider buildMMInterstitialAdWithAPID:@"foo" delegate:newFakeEvent];
        fooAdView should be_same_instance_as(newFooAdView);
        newFooAdView.delegate should equal(newFakeEvent);
        
        fooAdView should_not be_same_instance_as([provider buildMMInterstitialAdWithAPID:@"bar" delegate:fakeEvent]);
    });
    
    it(@"should return nil if the apid is empty", ^{
        [provider buildMMInterstitialAdWithAPID:@"" delegate:fakeEvent] should be_nil;
        [provider buildMMInterstitialAdWithAPID:nil delegate:fakeEvent] should be_nil;
    });
});


describe(@"MPMillennialInterstitialCustomEvent", ^{
    __block id<CedarDouble, MPInterstitialCustomEventDelegate> delegate;
    __block MPMillennialInterstitialCustomEvent *event;
    __block NSDictionary *info;
    __block FakeMMInterstitialAdView *interstitial;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPInterstitialCustomEventDelegate));
        event = [[[MPMillennialInterstitialCustomEvent alloc] init] autorelease];
        event.delegate = delegate;
    });
    
    context(@"when asked to fetch a configuration without an adunitid", ^{
        beforeEach(^{
            [event requestInterstitialWithCustomEventInfo:@{}];
        });
        
        it(@"should tell its delegate that it failed", ^{
            delegate should have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:)).with(event).and_with(nil);
        });
    });
    
    it(@"should allow automatic metrics tracking", ^{
        event.enableAutomaticImpressionAndClickTracking should equal(YES);
    });

    context(@"when asked to fetch a configuration with an adunitid", ^{
        beforeEach(^{
            info = @{@"adUnitID": @"millenialist"};

            interstitial = [[[FakeMMInterstitialAdView alloc] init] autorelease];
            fakeProvider.fakeMMAdViewInterstitial = interstitial;
        });
        
        describe(@"configuring the interstitial", ^{
            beforeEach(^{
                [event requestInterstitialWithCustomEventInfo:info];
            });
            
            it(@"should configure the interstitial correctly", ^{
                interstitial.apid should equal(@"millenialist");
                interstitial.delegate should equal(event);
            });
        });
        
        context(@"if there is already a cached ad", ^{
            beforeEach(^{
                interstitial.hasCachedAd = YES;
                [event requestInterstitialWithCustomEventInfo:info];
            });
            
            it(@"should tell the delegate that it's done loading", ^{
                delegate should have_received(@selector(interstitialCustomEvent:didLoadAd:)).with(event).and_with(interstitial);
            });
            
            it(@"should not ask the interstitial to fetch an ad", ^{
                interstitial.askedToFetchAd should equal(NO);
            });
        });
        
        context(@"if there is not a cached ad", ^{
            beforeEach(^{
                interstitial.hasCachedAd = NO;
                [event requestInterstitialWithCustomEventInfo:info];
            });
            
            it(@"should ask the interstitial to fetch an ad", ^{
                interstitial.askedToFetchAd should equal(YES);
            });
            
            context(@"if the interstitial successfully caches an ad", ^{
                beforeEach(^{
                    [interstitial simulateSuccessfullyCachingAd];
                });
                
                it(@"should tell the delegate", ^{
                    delegate should have_received(@selector(interstitialCustomEvent:didLoadAd:)).with(event).and_with(interstitial);
                });
            });
            
            context(@"if the interstitial fails to cache an ad", ^{
                beforeEach(^{
                    [interstitial simulateFailingToCacheAd];
                });
                
                it(@"should tell the delegate", ^{
                    delegate should have_received(@selector(interstitialCustomEvent:didFailToLoadAdWithError:)).with(event).and_with(nil);
                });
            });
        });
    });
    
    context(@"when asked to show the interstitial", ^{
        __block UIViewController *controller;
        
        beforeEach(^{
            interstitial = [[[FakeMMInterstitialAdView alloc] init] autorelease];
            fakeProvider.fakeMMAdViewInterstitial = interstitial;
            
            info = @{@"adUnitID": @"millenialist"};
            controller = [[[UIViewController alloc] init] autorelease];
            [event requestInterstitialWithCustomEventInfo:info];
        });
        
        context(@"when the interstitial has a cached ad", ^{
            beforeEach(^{
                interstitial.hasCachedAd = YES;
            });
            
            it(@"should display the ad", ^{
                interstitial.willSuccessfullyDisplayAd = YES;
                [event showInterstitialFromRootViewController:controller];
                interstitial.presentingViewController should equal(controller);
            });
            
            context(@"when the interstitial fails to display its cached ad", ^{
                beforeEach(^{
                    interstitial.willSuccessfullyDisplayAd = NO;
                    [event showInterstitialFromRootViewController:controller];
                });
                
                it(@"should tell its delegate that the ad expired", ^{
                    delegate should have_received(@selector(interstitialCustomEventDidExpire:)).with(event);
                });
            });
        });
        
        context(@"when the interstitial does not have a cached ad", ^{
            beforeEach(^{
                interstitial.hasCachedAd = NO;
                [event showInterstitialFromRootViewController:controller];
            });
            
            it(@"should tell its delegate that the ad expired", ^{
                delegate should have_received(@selector(interstitialCustomEventDidExpire:)).with(event);
            });
            
            it(@"should not present the interstitial", ^{
                interstitial.presentingViewController should be_nil;
            });
        });
    });
    
    describe(@"MMAdViewDelegate methods", ^{
        beforeEach(^{
            interstitial = [[[FakeMMInterstitialAdView alloc] init] autorelease];
            fakeProvider.fakeMMAdViewInterstitial = interstitial;
            
            info = @{@"adUnitID": @"millenialist"};
            [event requestInterstitialWithCustomEventInfo:info];
        });
        
        describe(@"-requestData", ^{
            it(@"should return the right set of params", ^{
                CLLocation *location = [[[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(30, 40)
                                                                      altitude:11
                                                            horizontalAccuracy:12
                                                              verticalAccuracy:10
                                                                     timestamp:[NSDate date]] autorelease];
                delegate stub_method("location").and_return(location);
                [event requestData] should equal(@{@"vendor": @"mopubsdk", @"lat": @"30", @"long": @"40"});
            });
        });
    });
});

SPEC_END

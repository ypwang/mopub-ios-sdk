#import "MPMillennialInterstitialAdapter.h"
#import "FakeMMInterstitialAdView.h"
#import "MPAdConfigurationFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPInstanceProvider (MillennialInterstitialsSpec)

- (MMAdView *)buildMMInterstitialAdWithAPID:(NSString *)apid delegate:(MPMillennialInterstitialAdapter *)delegate;

@end


SPEC_BEGIN(MPMillennialInterstitialAdapterSpec)

describe(@"MPMillennialInterstitialAdapter MPInstanceProvider additions", ^{
    __block MPMillennialInterstitialAdapter<CedarDouble> *fakeAdapter;
    __block MPInstanceProvider *provider;

    beforeEach(^{
        fakeAdapter = nice_fake_for([MPMillennialInterstitialAdapter class]);
        provider = [[[MPInstanceProvider alloc] init] autorelease];
    });

    it(@"should return a correctly configured ad view", ^{
        MMAdView *adView = [provider buildMMInterstitialAdWithAPID:@"foo" delegate:fakeAdapter];
        adView.delegate should equal(fakeAdapter);
    });

    it(@"should return a shared instance for each apid", ^{
        MMAdView *fooAdView = [provider buildMMInterstitialAdWithAPID:@"foo" delegate:fakeAdapter];
        fooAdView.delegate should equal(fakeAdapter);

        MPMillennialInterstitialAdapter<CedarDouble> *newFakeAdapter = nice_fake_for([MPMillennialInterstitialAdapter class]);
        MMAdView *newFooAdView = [provider buildMMInterstitialAdWithAPID:@"foo" delegate:newFakeAdapter];
        fooAdView should be_same_instance_as(newFooAdView);
        newFooAdView.delegate should equal(newFakeAdapter);

        fooAdView should_not be_same_instance_as([provider buildMMInterstitialAdWithAPID:@"bar" delegate:fakeAdapter]);
    });

    it(@"should return nil if the apid is empty", ^{
        [provider buildMMInterstitialAdWithAPID:@"" delegate:fakeAdapter] should be_nil;
        [provider buildMMInterstitialAdWithAPID:nil delegate:fakeAdapter] should be_nil;
    });
});

describe(@"MPMillennialInterstitialAdapter", ^{
    __block id<CedarDouble, MPBaseInterstitialAdapterDelegate> delegate;
    __block MPMillennialInterstitialAdapter *adapter;
    __block MPAdConfiguration *configuration;
    __block FakeMMInterstitialAdView *interstitial;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBaseInterstitialAdapterDelegate));

        adapter = [[[MPMillennialInterstitialAdapter alloc] initWithDelegate:delegate] autorelease];
    });

    context(@"when asked to fetch a configuration without an adunitid", ^{
        beforeEach(^{
            NSDictionary *headers = @{
                                      kAdTypeHeaderKey: @"millennial_full"
                                      };
            configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers
                                                                                       HTMLString:nil];

            [adapter _getAdWithConfiguration:configuration];
        });

        it(@"should tell its delegate that it failed", ^{
            delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);
        });
    });

    context(@"when asked to fetch a configuration with an adunitid", ^{
        beforeEach(^{
            NSDictionary *headers = @{
                                      kAdTypeHeaderKey: @"millennial_full",
                                      kNativeSDKParametersHeaderKey: @"{\"adUnitID\":\"millenialist\"}"
                                      };
            configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers
                                                                                       HTMLString:nil];
            interstitial = [[[FakeMMInterstitialAdView alloc] init] autorelease];
            fakeProvider.fakeMMAdViewInterstitial = interstitial;
        });

        describe(@"configuring the interstitial", ^{
            beforeEach(^{
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should configure the interstitial correctly", ^{
                interstitial.apid should equal(@"millenialist");
                interstitial.delegate should equal(adapter);
            });
        });

        context(@"if there is already a cached ad", ^{
            beforeEach(^{
                interstitial.hasCachedAd = YES;
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should tell the delegate that it's done loading", ^{
                delegate should have_received(@selector(adapterDidFinishLoadingAd:)).with(adapter);
            });

            it(@"should not ask the interstitial to fetch an ad", ^{
                interstitial.askedToFetchAd should equal(NO);
            });
        });

        context(@"if there is not a cached ad", ^{
            beforeEach(^{
                interstitial.hasCachedAd = NO;
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should ask the interstitial to fetch an ad", ^{
                interstitial.askedToFetchAd should equal(YES);
            });

            context(@"if the interstitial successfully caches an ad", ^{
                beforeEach(^{
                    [interstitial simulateSuccessfullyCachingAd];
                });

                it(@"should tell the delegate", ^{
                    delegate should have_received(@selector(adapterDidFinishLoadingAd:)).with(adapter);
                });
            });

            context(@"if the interstitial fails to cache an ad", ^{
                beforeEach(^{
                    [interstitial simulateFailingToCacheAd];
                });

                it(@"should tell the delegate", ^{
                    delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);
                });
            });
        });
    });

    context(@"when asked to show the interstitial", ^{
        __block UIViewController *controller;

        beforeEach(^{
            NSDictionary *headers = @{
                                      kAdTypeHeaderKey: @"millennial_full",
                                      kNativeSDKParametersHeaderKey: @"{\"adUnitID\":\"millenialist\"}"
                                      };
            configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers
                                                                                       HTMLString:nil];
            interstitial = [[[FakeMMInterstitialAdView alloc] init] autorelease];
            fakeProvider.fakeMMAdViewInterstitial = interstitial;
            controller = [[[UIViewController alloc] init] autorelease];
            [adapter _getAdWithConfiguration:configuration];
        });

        context(@"when the interstitial has a cached ad", ^{
            beforeEach(^{
                interstitial.hasCachedAd = YES;
            });

            it(@"should display the ad", ^{
                interstitial.willSuccessfullyDisplayAd = YES;
                [adapter showInterstitialFromViewController:controller];
                interstitial.presentingViewController should equal(controller);
            });

            context(@"when the interstitial fails to display its cached ad", ^{
                beforeEach(^{
                    interstitial.willSuccessfullyDisplayAd = NO;
                    [adapter showInterstitialFromViewController:controller];
                });

                it(@"should tell its delegate that the ad expired", ^{
                    delegate should have_received(@selector(interstitialDidExpireForAdapter:)).with(adapter);
                });
            });
        });

        context(@"when the interstitial does not have a cached ad", ^{
            beforeEach(^{
                interstitial.hasCachedAd = NO;
                [adapter showInterstitialFromViewController:controller];
            });

            it(@"should tell its delegate that the ad expired", ^{
                delegate should have_received(@selector(interstitialDidExpireForAdapter:)).with(adapter);
            });

            it(@"should not present the interstitial", ^{
                interstitial.presentingViewController should be_nil;
            });
        });
    });

    describe(@"MMAdViewDelegate methods", ^{
        beforeEach(^{
            NSDictionary *headers = @{
                                      kAdTypeHeaderKey: @"millennial_full",
                                      kNativeSDKParametersHeaderKey: @"{\"adUnitID\":\"millenialist\"}"
                                      };
            configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:headers
                                                                                       HTMLString:nil];
            interstitial = [[[FakeMMInterstitialAdView alloc] init] autorelease];
            fakeProvider.fakeMMAdViewInterstitial = interstitial;
            [adapter _getAdWithConfiguration:configuration];
        });

        describe(@"-requestData", ^{
            it(@"should return the right set of params", ^{
                CLLocation *location = [[[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(30, 40)
                                                                      altitude:11
                                                            horizontalAccuracy:12
                                                              verticalAccuracy:10
                                                                     timestamp:[NSDate date]] autorelease];
                delegate stub_method("location").and_return(location);
                [adapter requestData] should equal(@{@"vendor": @"mopubsdk", @"lat": @"30", @"long": @"40"});
            });
        });

        describe(@"adModalWillAppear", ^{
            it(@"should tell the delegate", ^{
                [adapter adModalWillAppear];
                delegate should have_received(@selector(interstitialWillAppearForAdapter:)).with(adapter);
            });
        });

        describe(@"adModalDidAppear", ^{
            it(@"should tell the delegate and track an impression", ^{
                [adapter adModalDidAppear];
                delegate should have_received(@selector(interstitialDidAppearForAdapter:)).with(adapter);
                fakeProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should contain(configuration);
            });
        });

        describe(@"adModalWasDismissed", ^{
            it(@"should tell the delegate", ^{
                [adapter adModalWasDismissed];
                delegate should have_received(@selector(interstitialWillDisappearForAdapter:)).with(adapter);
                delegate should have_received(@selector(interstitialDidDisappearForAdapter:)).with(adapter);
                delegate should have_received(@selector(interstitialDidExpireForAdapter:)).with(adapter);
            });
        });
    });
});

SPEC_END

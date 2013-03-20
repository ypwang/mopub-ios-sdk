#import "MPInterstitialCustomEventAdapter.h"
#import "MPAdConfigurationFactory.h"
#import "FakeInterstitialCustomEvent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

//TODO: when MPInterstitialAdController makes it to Specs, replace this with an import
@class MPInterstitialAdController;

SPEC_BEGIN(MPInterstitialCustomEventAdapterSpec)

describe(@"MPInterstitialCustomEventAdapter", ^{
    __block MPInterstitialCustomEventAdapter *adapter;
    __block id<CedarDouble, MPBaseInterstitialAdapterDelegate> delegate;
    __block MPAdConfiguration *configuration;
    __block FakeInterstitialCustomEvent *event;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBaseInterstitialAdapterDelegate));
        adapter = [[MPInterstitialCustomEventAdapter alloc] initWithDelegate:delegate];
        configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"FakeInterstitialCustomEvent"];
        event = [[[FakeInterstitialCustomEvent alloc] init] autorelease];
        fakeProvider.fakeInterstitialCustomEvent = event;
    });

    context(@"when asked to get an ad for a configuration", ^{
        context(@"when the requested custom event class exists", ^{
            beforeEach(^{
                configuration.customEventClassData = @{@"Zoology":@"Is for zoologists"};
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should create a new instance of the class and request the interstitial", ^{
                event.delegate should equal(adapter);
                event.customEventInfo should equal(configuration.customEventClassData);
            });
        });

        context(@"when the requested custom event class does not exist", ^{
            beforeEach(^{
                configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithCustomEventClassName:@"NonExistentCustomEvent"];
                [adapter _getAdWithConfiguration:configuration];
            });

            it(@"should not create an instance, and should tell its delegate that it failed to load", ^{
                event.delegate should be_nil;
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(nil);
            });
        });
    });

    context(@"when asked to show the interstitial", ^{
        __block UIViewController *controller;

        beforeEach(^{
            [adapter _getAdWithConfiguration:configuration];
            controller = [[[UIViewController alloc] init] autorelease];
            [adapter showInterstitialFromViewController:controller];
        });

        it(@"should ask the custom event class", ^{
            event.presentingViewController should equal(controller);
        });
    });

    describe(@"MPInterstitialCustomEventDelegate methods", ^{
        beforeEach(^{
            configuration.customEventClassData = @{@"Zoology":@"Is for zoologists"};
            [adapter _getAdWithConfiguration:configuration];
        });

        describe(@"when the custom event loads an ad", ^{
            beforeEach(^{
                [adapter interstitialCustomEvent:nil didLoadAd:nil];
            });

            it(@"should tell its delegate", ^{
                delegate should have_received(@selector(adapterDidFinishLoadingAd:)).with(adapter);
            });
        });

        describe(@"when the custom event fails to load an ad", ^{
            __block NSError *error;

            beforeEach(^{
                error = [NSErrorFactory genericError];
                [adapter interstitialCustomEvent:nil didFailToLoadAdWithError:error];
            });

            it(@"should tell its delegate", ^{
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(error);
            });
        });

        describe(@"when the custom event is about to show an ad", ^{
            beforeEach(^{
                [adapter interstitialCustomEventWillAppear:nil];
            });

            it(@"should tell its delegate", ^{
                delegate should have_received(@selector(interstitialWillAppearForAdapter:)).with(adapter);
                delegate should have_received(@selector(interstitialDidAppearForAdapter:)).with(adapter);

                [delegate.sent_messages[0] selector] should equal(@selector(interstitialWillAppearForAdapter:));
                [delegate.sent_messages[1] selector] should equal(@selector(interstitialDidAppearForAdapter:));
            });

            it(@"should log an impression (only once)", ^{
                fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations should contain(configuration);

                [adapter interstitialCustomEventWillAppear:nil];
                fakeProvider.lastFakeMPAnalyticsTracker.trackedImpressionConfigurations.count should equal(1);
            });
        });

        describe(@"when the custom event has dismissed an ad", ^{
            it(@"should tell its delegate", ^{
                [adapter interstitialCustomEventDidDisappear:nil];
                delegate should have_received(@selector(interstitialWillDisappearForAdapter:)).with(adapter);
                delegate should have_received(@selector(interstitialDidDisappearForAdapter:)).with(adapter);

                [delegate.sent_messages[0] selector] should equal(@selector(interstitialWillDisappearForAdapter:));
                [delegate.sent_messages[1] selector] should equal(@selector(interstitialDidDisappearForAdapter:));
            });
        });

        describe(@"when the custom event is about to leave the application", ^{
            it(@"should tell its delegate", ^{
                [adapter interstitialCustomEventWillLeaveApplication:nil];
                delegate should have_received(@selector(interstitialWillLeaveApplicationForAdapter:)).with(adapter);
            });
        });
    });
});

SPEC_END

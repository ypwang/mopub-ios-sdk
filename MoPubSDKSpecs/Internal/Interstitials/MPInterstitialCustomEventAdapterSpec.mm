#import "MPInterstitialCustomEventAdapter.h"
#import "MPAdConfigurationFactory.h"
#import "FakeInterstitialCustomEvent.h"
#import "MPInterstitialAdController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPInterstitialCustomEventAdapterSpec)

describe(@"MPInterstitialCustomEventAdapter", ^{
    __block MPInterstitialCustomEventAdapter *adapter;
    __block id<CedarDouble, MPBaseInterstitialAdapterDelegate> delegate;
    __block MPAdConfiguration *configuration;
    __block FakeInterstitialCustomEvent *event;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPBaseInterstitialAdapterDelegate));
        adapter = [[[MPInterstitialCustomEventAdapter alloc] initWithDelegate:delegate] autorelease];
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

    context(@"upon dealloc", ^{
        it(@"should inform its custom event instance that it is going away", ^{
            MPInterstitialCustomEventAdapter *anotherAdapter = [[MPInterstitialCustomEventAdapter alloc] initWithDelegate:nil];
            [anotherAdapter _getAdWithConfiguration:configuration];
            [anotherAdapter release];
            event.didUnload should equal(YES);
        });
    });
});

SPEC_END

#import "MPIAdInterstitialAdapter.h"
#import "MPAdConfigurationFactory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPIAdInterstitialAdapterSpec)

describe(@"MPIAdInterstitialAdapter", ^{
    __block id<CedarDouble, MPBaseInterstitialAdapterDelegate> delegate;
    __block MPIAdInterstitialAdapter *adapter;
    __block MPAdConfiguration *configuration;
    __block ADInterstitialAd<CedarDouble> *iAdInterstitial;

    beforeEach(^{
        iAdInterstitial = nice_fake_for([ADInterstitialAd class]);
        fakeProvider.fakeADInterstitialAd = iAdInterstitial;

        delegate = nice_fake_for(@protocol(MPBaseInterstitialAdapterDelegate));
        adapter = [[[MPIAdInterstitialAdapter alloc] initWithDelegate:delegate] autorelease];
        configuration = [MPAdConfigurationFactory defaultInterstitialConfigurationWithNetworkType:@"iAd_full"];
        [adapter _getAdWithConfiguration:configuration];
    });

    context(@"when asked to show the interstitial", ^{
        __block UIViewController *presentingController;

        beforeEach(^{
            presentingController = [[[UIViewController alloc] init] autorelease];
        });

        context(@"when the interstitial is loaded", ^{
            beforeEach(^{
                iAdInterstitial stub_method("isLoaded").and_return(YES);
                [adapter showInterstitialFromViewController:presentingController];
            });

            it(@"should tell its delegate that an interstitial will appear", ^{
                delegate should have_received(@selector(interstitialWillAppearForAdapter:)).with(adapter);
            });

            it(@"should tell the interstitial view controller to show the interstitial", ^{
                iAdInterstitial should have_received(@selector(presentFromViewController:)).with(presentingController);
            });

            it(@"should tell its delegate that an interstitial did appear", ^{
                delegate should have_received(@selector(interstitialDidAppearForAdapter:)).with(adapter);
            });

            it(@"should track an impression", ^{
                fakeProvider.sharedFakeMPAnalyticsTracker.trackedImpressionConfigurations should contain(configuration);
            });
        });

        context(@"when the interstitial is not loaded", ^{
            beforeEach(^{
                iAdInterstitial stub_method("isLoaded").and_return(NO);
                [adapter showInterstitialFromViewController:presentingController];
            });

            it(@"should not tell its delegate anything", ^{
                [delegate sent_messages] should be_empty;
            });

            it(@"should not tell the interstitial view controller to show the interstitial", ^{
                iAdInterstitial should_not have_received(@selector(presentFromViewController:));
            });
        });
    });

    context(@"when the interstitial has unloaded", ^{
        context(@"after having been displayed", ^{
            beforeEach(^{
                iAdInterstitial stub_method("isLoaded").and_return(YES);
                [adapter showInterstitialFromViewController:[[[UIViewController alloc] init] autorelease]];
                [adapter interstitialAdDidUnload:iAdInterstitial];
            });

            it(@"should tell its delegate", ^{
                delegate should have_received(@selector(interstitialWillDisappearForAdapter:)).with(adapter);
                delegate should have_received(@selector(interstitialDidDisappearForAdapter:)).with(adapter);
                delegate should have_received(@selector(interstitialDidExpireForAdapter:)).with(adapter);
            });
        });

        context(@"without being displayed", ^{
            beforeEach(^{
                [adapter interstitialAdDidUnload:iAdInterstitial];
            });

            it(@"should only tell its delegate that the interstitial expired", ^{
                delegate should_not have_received(@selector(interstitialWillDisappearForAdapter:)).with(adapter);
                delegate should_not have_received(@selector(interstitialDidDisappearForAdapter:)).with(adapter);
                delegate should have_received(@selector(interstitialDidExpireForAdapter:)).with(adapter);
            });
        });
    });

    context(@"when the interstitial loads", ^{
        it(@"should tell its delegate", ^{
            [adapter interstitialAdDidLoad:iAdInterstitial];
            delegate should have_received(@selector(adapterDidFinishLoadingAd:)).with(adapter);
        });
    });

    context(@"when the interstitial fails to load", ^{
        it(@"should tell its delegate", ^{
            NSError *error = [NSErrorFactory genericError];
            [adapter interstitialAd:iAdInterstitial didFailWithError:error];
            delegate should have_received(@selector(adapter:didFailToLoadAdWithError:)).with(adapter).and_with(error);
        });
    });

    context(@"when the interstitial is clicked", ^{
        it(@"should tell its delegate", ^{
            [adapter interstitialAdActionShouldBegin:iAdInterstitial willLeaveApplication:NO] should equal(YES);
            fakeProvider.sharedFakeMPAnalyticsTracker.trackedClickConfigurations should contain(configuration);
        });
    });
});

SPEC_END

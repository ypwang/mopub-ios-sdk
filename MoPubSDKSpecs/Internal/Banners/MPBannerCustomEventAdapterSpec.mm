#import "MPBannerCustomEventAdapter.h"
#import "MPAdConfigurationFactory.h"
#import "FakeBannerCustomEvent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPBannerCustomEventAdapterSpec)

describe(@"MPBannerCustomEventAdapter", ^{
    __block MPBannerCustomEventAdapter *adapter;
    __block id<CedarDouble, MPAdapterDelegate> delegate;
    __block MPAdConfiguration *configuration;
    __block FakeBannerCustomEvent *event;
    
    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPAdapterDelegate));
        adapter = [[[MPBannerCustomEventAdapter alloc] initWithAdapterDelegate:delegate] autorelease];
        configuration = [MPAdConfigurationFactory defaultBannerConfigurationWithCustomEventClassName:@"FakeBannerCustomEvent"];
        event = [[[FakeBannerCustomEvent alloc] init] autorelease];
        fakeProvider.FakeBannerCustomEvent = event;
    });
    
    context(@"when asked to get an ad for a configuration", ^{
        context(@"when the requested custom event class exists", ^{
            beforeEach(^{
                configuration.adSize = CGSizeMake(10,32);
                configuration.customEventClassData = @{@"Zoology":@"Is for zoologists"};
                [adapter _getAdWithConfiguration:configuration];
            });
            
            it(@"should create a new instance of the class and request the interstitial", ^{
                event.delegate should equal(adapter);
                event.size should equal(configuration.adSize);
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
    
    context(@"upon dealloc", ^{
        it(@"should inform its custom event instance that it is going away", ^{
            MPBannerCustomEventAdapter *anotherAdapter = [[MPBannerCustomEventAdapter alloc] initWithAdapterDelegate:nil];
            [anotherAdapter _getAdWithConfiguration:configuration];
            [anotherAdapter release];
            event.didUnload should equal(YES);
        });
    });
});

SPEC_END

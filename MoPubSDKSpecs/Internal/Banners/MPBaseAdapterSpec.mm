#import "MPBaseAdapter.h"
#import "FakeMPTimer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPConcreteBaseAdapter : MPBaseAdapter

- (void)simulateLoadingFinished;

@end

@implementation MPConcreteBaseAdapter

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
}

- (void)simulateLoadingFinished
{
    [self didStopLoading];
    [self.delegate adapter:self didFinishLoadingAd:nil shouldTrackImpression:YES];
}

@end

SPEC_BEGIN(MPBaseAdapterSpec)

describe(@"MPBaseAdapter", ^{
    __block MPConcreteBaseAdapter *adapter;
    __block id<CedarDouble, MPAdapterDelegate> delegate;
    
    beforeEach(^{
        delegate = nice_fake_for(@protocol(MPAdapterDelegate));
        adapter = [[[MPConcreteBaseAdapter alloc] initWithAdapterDelegate:delegate] autorelease];
    });
    
    describe(@"timing out requests", ^{
        context(@"when beginning a request", ^{
            __block FakeMPTimer *timeoutTimer;
            
            beforeEach(^{
                [adapter _getAdWithConfiguration:nil];
                timeoutTimer = [fakeProvider lastFakeMPTimerWithSelector:@selector(timeout)];
            });
            
            it(@"should schedule a timeout timer", ^{
                timeoutTimer.initialTimeInterval should equal(10);
                timeoutTimer.isScheduled should equal(YES);
            });
            
            context(@"before the timeout has elapsed", ^{
                context(@"when told that the request has finished (either successfully or not)", ^{
                    beforeEach(^{
                        [adapter simulateLoadingFinished];
                    });
                    
                    it(@"should invalidate the timeout timer", ^{
                        timeoutTimer.isValid should equal(NO);
                    });
                });
            });
            
            context(@"after the timeout has elapsed (without the timer being invalidated)", ^{
                beforeEach(^{
                    [timeoutTimer trigger];
                });
                
                it(@"should tell its delegate that the request failed", ^{
                    delegate should have_received(@selector(adapter:didFailToLoadAdWithError:));
                });
                
                context(@"when told later that the request has finished", ^{
                    it(@"should not tell its delegate", ^{
                        [delegate reset_sent_messages];
                        [adapter simulateLoadingFinished];
                        delegate.sent_messages should be_empty;
                    });
                });
            });
            
        });
    });
});

SPEC_END

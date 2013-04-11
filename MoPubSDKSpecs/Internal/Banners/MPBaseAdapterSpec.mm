#import "MPBaseAdapter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

@interface MPConcreteBaseAdapter : MPBaseAdapter

- (void)simulateLoadingFinished;

@end

@implementation MPConcreteBaseAdapter

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration containerSize:(CGSize)size
{
}

- (void)simulateLoadingFinished
{
    [self didStopLoading];
    [self.delegate adapter:self didFinishLoadingAd:nil];
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
            beforeEach(^{
                [adapter _getAdWithConfiguration:nil containerSize:CGSizeZero];
            });

            it(@"should timeout and tell the delegate about the failure after 10 seconds", ^{
                [fakeProvider advanceMPTimers:10];
                delegate should have_received(@selector(adapter:didFailToLoadAdWithError:));
            });

            context(@"when the request finishes before the timeout", ^{
                beforeEach(^{
                    [fakeProvider advanceMPTimers:5];
                    [adapter simulateLoadingFinished];
                });

                it(@"should not, later, fire the timeout", ^{
                    [delegate reset_sent_messages];
                    [fakeProvider advanceMPTimers:5];
                    delegate should_not have_received(@selector(adapter:didFailToLoadAdWithError:));
                });
            });
        });
    });
});

SPEC_END

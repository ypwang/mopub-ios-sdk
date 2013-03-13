#import "MPAdDestinationDisplayAgent.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(MPAdDestinationDisplayAgentSpec)

describe(@"MPAdDestinationDisplayAgent", ^{
    __block MPAdDestinationDisplayAgent *agent;

    beforeEach(^{
        agent = nil;
    });
    
    describe(@"when told to display the destination for a URL", ^{
        it(@"should bring up the loading indicator", ^{
            
        });
        
        it(@"should tell its delegate that an adActionWillBegin", ^{
            
        });
    });
    
    describe(@"when told to display a webview with an HTML string and a base URL", ^{
        it(@"should hide the loading indicator", ^{
            
        });
                
        it(@"should present a correctly configured webview", ^{
            
        });
        
        describe(@"MPAdBrowserControllerDelegate methods", ^{
            describe(@"-dismissBrowserController:animated:", ^{
                it(@"should tell its delegate that an adActionDidFinish", ^{
                    
                });
                
                it(@"should dismiss the browser modal", ^{
                    
                });
            });
            
            describe(@"-browserControllerWillLeaveApplication:", ^{
                it(@"should tell its delegate that an adActionWillLeaveApplication", ^{
                    
                });
                
                it(@"should dismiss the browser modal", ^{
                    
                });
            });
        });
    });
    
    describe(@"when told to ask the application to open the URL", ^{
        it(@"should hide the loading indicator", ^{
            
        });
        
        it(@"should tell its delegate that an adActionWillLeaveApplication", ^{
            
        });
        
        it(@"should ask the application to open the URL", ^{
            
        });
    });
        
    describe(@"when told to show a store kit item", ^{
        context(@"when store kit is available", ^{
            it(@"should tell store kit to load the store item", ^{
                
            });
            
            context(@"when the load succeeds", ^{
                it(@"should hide the loading indicator", ^{
                    
                });
                
                it(@"should present the store", ^{
                    
                });
                
                context(@"when the person leaves the store", ^{
                    it(@"should dismiss the store", ^{
                        
                    });
                    
                    it(@"should tell its delegate that an adActionDidFinish", ^{
                        
                    });
                });
            });
            
            context(@"when the load fails", ^{
                it(@"should hide the loading indicator", ^{
                    
                });
                
                it(@"should tell its delegate that an adActionWillLeaveApplication", ^{
                    
                });
                
                it(@"should ask the application to open the fallback URL", ^{
                    
                });
            });
            
            context(@"when the user cancels and then the load succedds", ^{
                it(@"should not show the store", ^{
                    
                });
            });
        });
        
        context(@"when store kit is not available (iOS < 6)", ^{
            it(@"should hide the loading indicator", ^{
                
            });
            
            it(@"should tell its delegate that an adActionWillLeaveApplication", ^{
                
            });
            
            it(@"should ask the application to open the fallback URL", ^{
                
            });
        });
    });
    
    describe(@"when the resolution of the URL fails", ^{
        it(@"should hide the loading indicator", ^{
            
        });
        
        it(@"should tell the delegate that an adActionDidFinish", ^{
            
        });
    });
    
    describe(@"when the user cancels by closing the loading indicator", ^{
        it(@"should cancel the request", ^{
            //whatever that means
        });
        
        it(@"should tell the delegate that an adActionDidFinish", ^{
            
        });
    });
    
    describe(@"happy path test ", ^{
        it(@"should work", ^{
            //pass in the URL
            //grab the URL connection and make it succeed
            //assert that the visible view controller is a web view
            //assert that the web view's content is whatever we passed the connection
        });
    });
});

SPEC_END

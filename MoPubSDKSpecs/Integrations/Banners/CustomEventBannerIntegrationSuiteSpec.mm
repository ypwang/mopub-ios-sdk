using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CustomEventBannerIntegrationSuiteSpec)

describe(@"CustomEventBannerIntegrationSuite", ^{

    //think about foregrounding?
    //handle rotateToOrientation
    context(@"loading an ad", ^{
        it(@"should tell the custom event to load the ad, with the appropriate size", ^{

        });

        it(@"should not have a refresh timer scheduled yet", ^{

        });

        context(@"when told to rotate", ^{
            it(@"should tell the custom event", ^{

            });
        });

        context(@"when the ad loads successfully", ^{
            //SHARED: SHOWING A LOADED AD VIEW {
            it(@"should tell the ad view delegate", ^{

            });

            it(@"should put the ad view on screen", ^{

            });

            it(@"should return the correct ad content size", ^{

            });

            it(@"should track an impression", ^{

            });

            it(@"should cancel the timeout timer", ^{

            });

            it(@"should start the refresh timer", ^{

            });
            //}

            context(@"when the user taps on the ad", ^{
                it(@"should tell the delegate and track a click", ^{
                    //willPresentModal
                });

                it(@"(the presented modal) should be presented with the correct view controller", ^{

                });

                it(@"should pause its refresh timer", ^{

                });

                context(@"when the user finishes playing with the ad", ^{
                    it(@"should tell the delegate", ^{
                        //didDismiss
                    });

                    it(@"should resume the refresh timer", ^{

                    });
                });

                context(@"when the user leaves the application from the ad", ^{
                    it(@"should tell the delegate", ^{
                        //willLeave
                    });

                    it(@"should resume the refresh timer", ^{

                    });
                });
            });

            context(@"and then the refresh timer fires", ^{
                it(@"should start loading a new ad (passing in the original view size)", ^{

                });

                context(@"when told to rotate", ^{
                    it(@"should tell both the loaded custom event, and the new custom event", ^{

                    });
                });

                context(@"when the new ad arrives", ^{
                    context(@"and the user has not tapped on the first ad", ^{
                        //SHARED: SHOWING A LOADED AD VIEW
                    });

                    context(@"and the user has tapped on the first ad", ^{
                        context(@"and the user is in the middle of an ad action", ^{
                            it(@"should not put the new ad view on screen", ^{

                            });

                            it(@"should not tell the ad view delegate", ^{

                            });

                            it(@"should not track an impression", ^{

                            });

                            it(@"should cancel the timeout timer", ^{

                            });

                            it(@"should not start the refresh timer", ^{

                            });

                            context(@"and then the user finishes an ad action", ^{
                                //SHARED: SHOWING A LOADED AD VIEW
                            });

                            context(@"and then the user leaves the application", ^{
                                //SHARED: SHOWING A LOADED AD VIEW
                            });
                        });
                    });
                });

                context(@"when the new ad fails to arrive", ^{
                    //SHARED: THE FAILOVER DANCE WITH THE CONFIGURED TIMEOUT
                    //use value from config
                });
            });
        });

        context(@"when the ad fails to load", ^{
            //SHARED: THE FAILOVER DANCE WITH THE DEFAULT TIMEOUT {
            it(@"should request the failover URL", ^{

            });

            it(@"should not tell the delegate anything", ^{

            });

            it(@"should not have a refresh timer", ^{

            });

            context(@"if the failover URL returns clear", ^{
                it(@"should tell the delegate that it failed", ^{

                });

                it(@"should schedule the refresh timer", ^{
                    //use default 60 seconds
                });
            });

            //}
        });


        context(@"when the timeout occurs (before the ad responds)", ^{
            //SHARED: THE FAILOVER DANCE WITH THE DEFAULT TIMEOUT

            context(@"when the ad does eventually load", ^{
                it(@"should ignore it (don't tell the delegate, don't put it onscreen, don't track an impression)", ^{

                });
            });

            context(@"when the ad eventually fails", ^{
                it(@"should ignore it (don't do the failover dance)", ^{

                });
            });
        });
    });

    context(@"when loading an ad with auto-refresh turned off", ^{
        //SHARED: AN AD LOAD THAT DOES NOT REFRESH {
            it(@"should tell the custom event to load the ad, with the appropriate size", ^{

            });

            context(@"when the ad loads successfully", ^{
                it(@"should tell the ad view delegate", ^{

                });

                it(@"should put the ad view on screen", ^{

                });

                it(@"should track an impression", ^{

                });

                it(@"should cancel the timeout timer", ^{

                });

                it(@"should *NOT* start the refresh timer", ^{

                });
            });

            context(@"when the ad fails to load", ^{
                //SHARED: THE FAILOVER DANCE WITH THE DEFAULT TIMEOUT
            });
        //}

        context(@"when the application foregrounds", ^{
            it(@"should not refresh the ad", ^{

            });
        });
    });

    context(@"when loading an ad that has no refresh timeout configured", ^{
        //SHARED: AN AD LOAD THAT DOES NOT REFRESH
    });
});

SPEC_END

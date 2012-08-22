//
//  NetworkManager.m
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import "NetworkManager.h"
#import "AppDelegate.h"
#import "EarthquakeFetchOperation.h"
#import "Reachability.h"

static NetworkManager __strong *sharedManager = nil;

@implementation NetworkManager

@synthesize fetchQueue = _fetchQueue;
@synthesize baseURLString = _baseURLString;
@synthesize mainContext = _mainContext;
@synthesize networkOnline = _networkOnline;

+ (NetworkManager *)sharedManager {
    static dispatch_once_t pred; dispatch_once(&pred, ^{
        sharedManager = [[self alloc] init];
        [sharedManager setFetchQueue:[[NSOperationQueue alloc] init]];
        [sharedManager setBaseURLString:@"http://earthquake.usgs.gov/"];
        [sharedManager setMainContext:[(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext]];
        //Assume the network is up to start with
        [sharedManager setNetworkOnline:YES];
        [[NSNotificationCenter defaultCenter] addObserver:sharedManager selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];

    });
    return sharedManager;
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    if ([curReach currentReachabilityStatus]==NotReachable) {
        [self setNetworkOnline:NO];
    } else {
        [self setNetworkOnline:YES];
    }
}

-(NSURL *) baseURL {
    return [NSURL URLWithString:self.baseURLString];
}

-(NSURL *) urlForRelativePath:(NSString *) relativePath {
    return [NSURL URLWithString:relativePath relativeToURL:self.baseURL];
}

-(void) queuePageFetchForRelativePath:(NSString *) relativePath {
    EarthquakeFetchOperation *mainEFO = [[EarthquakeFetchOperation alloc] init];
    [mainEFO setUrlForJSONData:[self urlForRelativePath:relativePath]];
    [mainEFO setMainContext:self.mainContext];
    [self.fetchQueue addOperation:mainEFO];
}

-(void) startMainPageFetch {
    [self queuePageFetchForRelativePath:@"/earthquakes/feed/geojson/significant/month"];
}

@end

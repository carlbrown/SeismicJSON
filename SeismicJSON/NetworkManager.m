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
@synthesize urlMap = _urlMap;

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
    EarthquakeFetchOperation *earthquakeFetchOperation = [[EarthquakeFetchOperation alloc] init];
    [earthquakeFetchOperation setUrlForJSONData:[self urlForRelativePath:relativePath]];
    [earthquakeFetchOperation setMainContext:self.mainContext];
    [earthquakeFetchOperation setDelegate:self];
    [self.fetchQueue addOperation:earthquakeFetchOperation];
}

-(void) startMainPageFetch {
    [self queuePageFetchForRelativePath:@"/earthquakes/feed/geojson/significant/month"];
}

-(NSDictionary *) urlMap {
    if (_urlMap==nil) {
        _urlMap = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"USGSURLMapData" ofType:@"plist"]];
    }
    return _urlMap;
}

-(NSArray *) availableTimeFrames {
    if (!self.isNetworkOnline) {
        UIAlertView *networkAlertView = [[UIAlertView alloc] initWithTitle:@"Network Offline" message:@"Cannot talk to network" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [networkAlertView show];

        return nil;
    }
    return [self.urlMap allKeys];
}

-(NSArray *) significanceFiltersForTimeFrame:(NSString *) timeFrame {
    if (!self.isNetworkOnline) {
        UIAlertView *networkAlertView = [[UIAlertView alloc] initWithTitle:@"Network Offline" message:@"Cannot talk to network" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [networkAlertView show];
        
        return nil;
    }
    return [[self.urlMap objectForKey:timeFrame] allKeys];
}

-(NSString *) relativeJSONURLForTimeFrame:(NSString *)timeFrame andSignificance:(NSString *) significance {
    if (!self.isNetworkOnline) {
        UIAlertView *networkAlertView = [[UIAlertView alloc] initWithTitle:@"Network Offline" message:@"Cannot talk to network" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [networkAlertView show];
        
        return nil;
    }
    return [[self.urlMap objectForKey:timeFrame] objectForKey:significance];
}

-(void) fetchDidFailWithError:(NSError *) error {
    //Don't give the user an error if the network is already offline
    if (self.isNetworkOnline) {
        UIAlertView *networkAlertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedRecoverySuggestion] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [networkAlertView show];
        [self setNetworkOnline:NO];
    }
    
}

@end

//
//  NetworkManager.m
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import "NetworkManager.h"
#import "AppDelegate.h"
#import "EarthquakeFetchOperation.h"
#import "ImageFetchOperation.h"
#import "Reachability.h"

static NetworkManager __strong *sharedManager = nil;

@interface NetworkManager ()
@property (nonatomic, strong) NSString *baseURLString;
@property (nonatomic, strong) NSOperationQueue *fetchQueue;
@property (nonatomic, weak) NSManagedObjectContext *mainContext;
@property (nonatomic, assign, getter = isNetworkOnline) BOOL networkOnline;
@property (nonatomic, strong, readonly) NSDictionary *urlMap;
@property (nonatomic, strong) Reachability *hostReach;
@property (atomic, readwrite) NSUInteger activeFetches;
@property (nonatomic, strong, readonly) NSString *cachedImageDirectory;


-(NSURL *) baseURL;
-(NSURL *) urlForRelativePath:(NSString *) relativePath;

@end

@implementation NetworkManager

@synthesize fetchQueue = _fetchQueue;
@synthesize baseURLString = _baseURLString;
@synthesize mainContext = _mainContext;
@synthesize networkOnline = _networkOnline;
@synthesize urlMap = _urlMap;
@synthesize hostReach = _hostReach;
@synthesize cachedImageDirectory = _cachedImageDirectory;
@synthesize activeFetches = _activeFetches;

+ (NetworkManager *)sharedManager {
    static dispatch_once_t pred; dispatch_once(&pred, ^{
        sharedManager = [[self alloc] init];
        [sharedManager setFetchQueue:[[NSOperationQueue alloc] init]];
        [sharedManager setBaseURLString:@"http://earthquake.usgs.gov/"];
        [sharedManager setMainContext:[(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext]];
        //Assume the network is up to start with
        [sharedManager setNetworkOnline:YES];
        [[NSNotificationCenter defaultCenter] addObserver:sharedManager selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
        [sharedManager setActiveFetches:0];
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

-(NSURL *) imageURLForImageFileName:(NSString *) imageFilename {
    NSString *imageRelativePath = [@"/images/globes/" stringByAppendingPathComponent:imageFilename];
    return [NSURL URLWithString:imageRelativePath relativeToURL:self.baseURL];
}

-(void) queuePageFetchForRelativePath:(NSString *) relativePath {
    EarthquakeFetchOperation *earthquakeFetchOperation = [[EarthquakeFetchOperation alloc] init];
    [earthquakeFetchOperation setUrlToFetch:[self urlForRelativePath:relativePath]];
    [earthquakeFetchOperation setMainContext:self.mainContext];
    [earthquakeFetchOperation setDelegate:self];
    [self.fetchQueue addOperation:earthquakeFetchOperation];
}

-(void) startMainPageFetch {
    [self setHostReach:[Reachability reachabilityWithHostName:[self.baseURL host]]];
    [self.hostReach startNotifier];

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
        UIAlertView *networkAlertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[[error userInfo] description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [networkAlertView show];
        [self setNetworkOnline:NO];
    }
    
}

-(void) incrementActiveFetches {
    self.activeFetches++;
    if (![[UIApplication sharedApplication] isNetworkActivityIndicatorVisible]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

-(void) decrementActiveFetches {
    if (self.activeFetches > 1) {
        self.activeFetches--;
        return;
    }
    self.activeFetches=0;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(NSString *) cachedImageDirectory {
    if (_cachedImageDirectory==nil) {
        _cachedImageDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"cachedImages"];
    }
    
    return _cachedImageDirectory;
}

-(void) fetchImagewithFilename:(NSString *) filename andNotifyTarget:(NSObject <ImageFetchDelegate> *) target {
    
    //If the file already exists, don't bother to fetch it again
    NSString *fullFilePath = [[self cachedImageDirectory] stringByAppendingPathComponent:filename];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullFilePath]) {
        [target imageDidBecomeAvailableAtPath:fullFilePath];
        return;
    }
    
    ImageFetchOperation *imageFetchOperation = [[ImageFetchOperation alloc] init];
    [imageFetchOperation setUrlToFetch:[self imageURLForImageFileName:filename]];
    [imageFetchOperation setNotificationTarget:target];
    [self.fetchQueue addOperation:imageFetchOperation];

}

@end

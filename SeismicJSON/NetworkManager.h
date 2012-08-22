//
//  NetworkManager.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import <Foundation/Foundation.h>

#import "EarthquakeFetchOperation.h"

@protocol ImageFetchDelegate;

@class Reachability;

@interface NetworkManager : NSObject <FetchNotifierDelegate>

+ (NetworkManager *)sharedManager;

-(void) queuePageFetchForRelativePath:(NSString *) relativePath;
-(void) startMainPageFetch;
-(void) fetchImagewithFilename:(NSString *) filename andNotifyTarget:(NSObject <ImageFetchDelegate> *) target;

-(NSArray *) availableTimeFrames;
-(NSArray *) significanceFiltersForTimeFrame:(NSString *) timeFrame;
-(NSString *) relativeJSONURLForTimeFrame:(NSString *)timeFrame andSignificance:(NSString *) significance;
-(NSString *) cachedImageDirectory;

@end

@protocol ImageFetchDelegate <NSObject>

-(void) imageDidBecomeAvailableAtPath:(NSString *) path;

@end


//
//  NetworkManager.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "EarthquakeFetchOperation.h"

@class Reachability;

@interface NetworkManager : NSObject <FetchNotifierDelegate>

+ (NetworkManager *)sharedManager;

-(void) queuePageFetchForRelativePath:(NSString *) relativePath;
-(void) startMainPageFetch;

-(NSArray *) availableTimeFrames;
-(NSArray *) significanceFiltersForTimeFrame:(NSString *) timeFrame;
-(NSString *) relativeJSONURLForTimeFrame:(NSString *)timeFrame andSignificance:(NSString *) significance;

@end


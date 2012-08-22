//
//  earthquakeFetchOperation.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import <Foundation/Foundation.h>

@protocol FetchNotifierDelegate;

@interface EarthquakeFetchOperation : NSOperation <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURL *urlForJSONData;
@property (nonatomic, weak) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, assign, getter=isDone) BOOL done;
@property (nonatomic, assign) NSURLConnection *connection;
@property (nonatomic, retain) NSHTTPURLResponse *response;

@property (nonatomic, weak) NSObject<FetchNotifierDelegate> *delegate;

-(void) finish;

@end

@protocol FetchNotifierDelegate <NSObject>
-(void) fetchDidFailWithError:(NSError *) error;
@end

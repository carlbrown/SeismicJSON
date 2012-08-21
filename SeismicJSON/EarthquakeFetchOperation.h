//
//  earthquakeFetchOperation.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EarthquakeFetchOperation : NSOperation <NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURL *urlForJSONData;
@property (nonatomic, weak) NSManagedObjectContext *mainContext;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, assign, getter=isDone) BOOL done;
@property (nonatomic, assign) NSURLConnection *connection;
@property (nonatomic, retain) NSHTTPURLResponse *response;

-(void) finish;

@end

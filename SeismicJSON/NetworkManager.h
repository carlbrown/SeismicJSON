//
//  NetworkManager.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

+ (NetworkManager *)sharedManager;

@property (nonatomic, strong) NSString *baseURLString;
@property (nonatomic, strong) NSOperationQueue *fetchQueue;
@property (nonatomic, weak) NSManagedObjectContext *mainContext;
@property (nonatomic, assign, getter = isNetworkOnline) BOOL networkOnline;

-(NSURL *) baseURL;
-(NSURL *) urlForRelativePath:(NSString *) relativePath;

-(void) queuePageFetchForRelativePath:(NSString *) relativePath;
-(void) startMainPageFetch;

@end

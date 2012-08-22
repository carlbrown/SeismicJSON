//
//  ImageFetchOperation.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/22/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import "BaseFetchOperation.h"

@protocol ImageFetchDelegate;

@interface ImageFetchOperation : BaseFetchOperation

@property (nonatomic, strong) NSObject<ImageFetchDelegate> *notificationTarget;

@end

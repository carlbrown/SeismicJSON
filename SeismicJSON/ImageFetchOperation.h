//
//  ImageFetchOperation.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/22/12.
//  Copyright (c) 2012 PDAgent. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import "BaseFetchOperation.h"

@protocol ImageFetchDelegate;

@interface ImageFetchOperation : BaseFetchOperation

@property (nonatomic, strong) NSObject<ImageFetchDelegate> *notificationTarget;

@end

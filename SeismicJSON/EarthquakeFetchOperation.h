//
//  EarthquakeFetchOperation.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import <Foundation/Foundation.h>
#import "BaseFetchOperation.h"

@interface EarthquakeFetchOperation : BaseFetchOperation
@property (nonatomic, weak) NSManagedObjectContext *mainContext;

@end


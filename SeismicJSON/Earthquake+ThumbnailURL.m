//
//  Earthquake+ThumbnailURL.m
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import "Earthquake+ThumbnailURL.h"

@implementation Earthquake (ThumbnailURL)

- (NSString *) simplifiedLatApproximationString {
    return [NSString stringWithFormat:@"%-.0f",(floor([self.latitude doubleValue]/5.0f)*5.0f)];
}

- (NSString *) simplifiedLongApproximationString {
    return [NSString stringWithFormat:@"%-.0f",(floor([self.longitude doubleValue]/5.0f)*5.0f)];
}

- (NSString *) thumbnailFilenameString {
    return [NSString stringWithFormat:@"%@_%@.jpg",self.simplifiedLatApproximationString,self.simplifiedLongApproximationString];
}

@end

//
//  Earthquake+ThumbnailURL.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import "Earthquake.h"

@interface Earthquake (ThumbnailURL)

- (NSString *) simplifiedLatApproximationString;
- (NSString *) simplifiedLongApproximationString;
- (NSString *) thumbnailFilenameString;

@end

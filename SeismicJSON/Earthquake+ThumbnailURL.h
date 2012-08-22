//
//  Earthquake+ThumbnailURL.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import "Earthquake.h"

@interface Earthquake (ThumbnailURL)

- (NSString *) simplifiedLatApproximationString;
- (NSString *) simplifiedLongApproximationString;
- (NSString *) thumbnailFilenameString;

@end

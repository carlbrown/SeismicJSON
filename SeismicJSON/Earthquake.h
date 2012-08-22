//
//  Earthquake.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Earthquake : NSManagedObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * webLinkToUSGS;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * magnitude;

@end

//
//  EarthquakeTableViewCell.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import <UIKit/UIKit.h>

@class ActivityIndicatingImageView;

@interface EarthquakeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *magnitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet ActivityIndicatingImageView *globeThumbnailImageView;

@end

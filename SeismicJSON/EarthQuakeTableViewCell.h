//
//  EarthQuakeTableViewCell.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ActivityIndicatingImageView;

@interface EarthQuakeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *magnitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet ActivityIndicatingImageView *globeThumbnailImageView;

@end

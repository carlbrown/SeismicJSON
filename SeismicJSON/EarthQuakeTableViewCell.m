//
//  EarthQuakeTableViewCell.m
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import "EarthQuakeTableViewCell.h"

@implementation EarthQuakeTableViewCell
@synthesize magnitudeLabel;
@synthesize locationLabel;
@synthesize dateLabel;
@synthesize globeThumbnailImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

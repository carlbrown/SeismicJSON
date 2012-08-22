//
//  EarthQuakeTableViewCell.m
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import "EarthQuakeTableViewCell.h"
#import "ActivityIndicatingImageView.h"

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

-(void) prepareForReuse {
    [self.globeThumbnailImageView setImage:nil];
    [self.globeThumbnailImageView setImageFileName:nil];
    [self.magnitudeLabel setText:nil];
    [self.locationLabel setText:nil];
    [self.dateLabel setText:nil];
}

@end

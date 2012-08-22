//
//  ActivityIndicatingImageView.m
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import "ActivityIndicatingImageView.h"

@implementation ActivityIndicatingImageView
@synthesize activityIndicator = _activityIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void) awakeFromNib {
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activityIndicator setFrame:self.frame];
    [_activityIndicator setHidesWhenStopped:YES];
    [self addSubview:_activityIndicator];
    [_activityIndicator startAnimating];
}

-(void) setImage:(UIImage *)image {
    [super setImage:image];
    if (image) {
        [self.activityIndicator stopAnimating];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

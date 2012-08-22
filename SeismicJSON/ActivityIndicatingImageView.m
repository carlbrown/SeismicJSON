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
@synthesize imageFileName = _imageFileName;

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

-(void) setImageFileName:(NSString *)imageFileName {
    _imageFileName = imageFileName;
    [[NetworkManager sharedManager] fetchImagewithFilename:imageFileName andNotifyTarget:self];
    
}

-(void) imageDidBecomeAvailableAtPath:(NSString *) path {
    dispatch_async(dispatch_get_current_queue(), ^{
        [self setImage:[UIImage imageWithContentsOfFile:path]];
    });
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

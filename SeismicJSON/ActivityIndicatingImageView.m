//
//  ActivityIndicatingImageView.m
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
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
    } else {
        [self.activityIndicator startAnimating];
    }
}

-(void) setImageFileName:(NSString *)imageFileName {
    _imageFileName = imageFileName;
    if (_imageFileName==nil) {
        [self setImage:nil];
        return;
    }
    
    //If the file already exists, don't bother to fetch it again
    NSString *fullFilePath = [[[NetworkManager sharedManager] cachedImageDirectory] stringByAppendingPathComponent:_imageFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullFilePath]) {
        [self imageDidBecomeAvailableAtPath:fullFilePath];
        return;
    }

    [[NetworkManager sharedManager] fetchImagewithFilename:imageFileName andNotifyTarget:self];
    
}

-(void) imageDidBecomeAvailableAtPath:(NSString *) path {
    if (![[path lastPathComponent] isEqualToString:self.imageFileName]) {
        NSLog(@"Warning: notified of incorrect file:%@, should have been %@",[path lastPathComponent],self.imageFileName);
        //try again
        [self setImageFileName:self.imageFileName];
        return;
    }
    //load image off the main queue
    UIImage *imageToLoad=[UIImage imageWithContentsOfFile:path];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setImage:imageToLoad];
        [self setNeedsDisplay];
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

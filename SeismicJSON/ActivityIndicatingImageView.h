//
//  ActivityIndicatingImageView.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import <UIKit/UIKit.h>

#import "NetworkManager.h"

@interface ActivityIndicatingImageView : UIImageView <ImageFetchDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *imageFileName;

@end

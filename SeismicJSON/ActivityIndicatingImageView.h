//
//  ActivityIndicatingImageView.h
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NetworkManager.h"

@interface ActivityIndicatingImageView : UIImageView <ImageFetchDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *imageFileName;

@end

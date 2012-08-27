//
//  ImageFetchOperation.m
//  SeismicJSON
//
//  Created by Carl Brown on 8/22/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import "ImageFetchOperation.h"
#import "NetworkManager.h"

@implementation ImageFetchOperation

@synthesize notificationTarget = _notificationTarget;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([self isCancelled]) {
        [self finish];
        return;
    }
    
    if (self.response.statusCode==200) {
        NSError *error=nil;
        NSString *filename = [self.urlToFetch lastPathComponent];
        NSString *cachedImageDirectory = [[NetworkManager sharedManager] cachedImageDirectory];
        NSString *fullFilePath = [cachedImageDirectory stringByAppendingPathComponent:filename];
        NSLog(@"About to write file: %@",fullFilePath);
        if (![self.fetchedData writeToFile:fullFilePath options:NSDataWritingAtomic error:&error]) {
            NSLog(@"error occurred writing file: %@",[error localizedDescription]);
            BOOL isDirectory=NO;
            if (![[NSFileManager defaultManager] fileExistsAtPath:cachedImageDirectory isDirectory:&isDirectory]) {
                NSError *error=nil;
                if (![[NSFileManager defaultManager] createDirectoryAtPath:cachedImageDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
                    NSLog(@"Error creating directory '%@':%@",cachedImageDirectory,[error localizedDescription]);
                } else {
                    if (![self.fetchedData writeToFile:fullFilePath options:NSDataWritingAtomic error:&error]) {
                        NSLog(@"error occurred writing file again: %@",[error localizedDescription]);
                    }
                }
            }

        }
        if (self.notificationTarget) {
            [self.notificationTarget imageDidBecomeAvailableAtPath:fullFilePath];
        }
    }
    
    [self finish];
}

@end

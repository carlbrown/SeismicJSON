//
//  EarthquakeFetchOperation.m
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import "EarthquakeFetchOperation.h"
#import "Earthquake.h"

@implementation EarthquakeFetchOperation

@synthesize urlForJSONData = _urlForJSONData;
@synthesize mainContext = _mainContext;
@synthesize jsonData = _jsonData;
@synthesize done = _done;
@synthesize connection = _connection;
@synthesize response = _response;
@synthesize delegate = _delegate;

- (void)main {
    if ([self isCancelled]) {
        return;
    }
    if (!_urlForJSONData) {
        NSLog(@"Cannot start without a URL");
        return;
    }
    if (!_mainContext) {
        NSLog(@"Cannot start without a Primary Managed Object Context");
        return;
    }

    [self setJsonData:[NSMutableData data]]; //Initialize
    NSURLRequest *request = [NSURLRequest requestWithURL:[self urlForJSONData]];

    [self setConnection:[NSURLConnection connectionWithRequest:request delegate:self]];

    CFRunLoopRun();

}

-(void) finish {
    [self setDone:YES];
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([self isCancelled]) {
        [[self connection] cancel];
        [self finish];
        return;
    }
    
    [self setResponse:(NSHTTPURLResponse *) response];
    [self setJsonData:[NSMutableData data]]; //truncate

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if ([self isCancelled]) {
        [[self connection] cancel];
        [self finish];
        return;
    }
    [self.jsonData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error connecting: %@",[error localizedDescription]);
    if (self.delegate) {
        [self.delegate fetchDidFailWithError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([self isCancelled]) {
        [self finish];
        return;
    }
    
    NSError *error=nil;
    
    
    id objectFromJSON = [NSJSONSerialization JSONObjectWithData:self.jsonData options:0 error:&error];
    if (objectFromJSON) {
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [context setParentContext:[self mainContext]];

        
        NSDictionary *jsonDict = (NSDictionary *) objectFromJSON;
        
        if (jsonDict) {
            
            NSArray *events = [jsonDict objectForKey:@"features"];
            
            if (events) {
                
                for (NSDictionary *eventDict in events) {
                    
                    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Earthquake class]) inManagedObjectContext:context];
                    
                    [newManagedObject setValue:[eventDict valueForKeyPath:@"properties.place"] forKey:@"location"];
                    
                    NSDate *eventDate = [NSDate dateWithTimeIntervalSince1970:[[eventDict valueForKeyPath:@"properties.time"] doubleValue]];
                    [newManagedObject setValue:eventDate forKey:@"date"]; 
                    
                    NSNumber *eventLat = [NSNumber numberWithDouble:[[[eventDict valueForKeyPath:@"geometry.coordinates"] objectAtIndex:0] doubleValue]];
                    [newManagedObject setValue:eventLat forKey:@"latitude"];
                    
                    NSNumber *eventLong =[NSNumber numberWithDouble:[[[eventDict valueForKeyPath:@"geometry.coordinates"] objectAtIndex:1] doubleValue]];

                    [newManagedObject setValue:eventLong forKey:@"longitude"];
                    
                    NSNumber *magnitude = [NSNumber numberWithFloat:[[eventDict valueForKeyPath:@"properties.mag"] floatValue]];
                    
                    [newManagedObject setValue:magnitude forKey:@"magnitude"];
                    
                    NSString *webPath = [@"http://earthquake.usgs.gov" stringByAppendingPathComponent:[eventDict valueForKeyPath:@"properties.url"]];

                    [newManagedObject setValue:webPath forKey:@"webLinkToUSGS"];

                }
                
                // Save the context.
                error = nil;
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    NSError *error = nil;
                    if (![self.mainContext save:&error]) {
                        // Replace this implementation with code to handle the error appropriately.
                        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
                        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                        abort();
                    }
                });
                
            }
        }
    }
    
}

@end

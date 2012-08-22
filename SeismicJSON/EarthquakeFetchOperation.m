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
    
    if (self.delegate) {
        [self.delegate incrementActiveFetches];
    }
    
    [self setConnection:[NSURLConnection connectionWithRequest:request delegate:self]];

    CFRunLoopRun();

}

-(void) finish {
    [self setDone:YES];
    if (self.delegate) {
        [self.delegate decrementActiveFetches];
    }
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
    [self finish];
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
                    
                    NSString *eventLocation = [eventDict valueForKeyPath:@"properties.place"];
                    NSDate *eventDate = [NSDate dateWithTimeIntervalSince1970:[[eventDict valueForKeyPath:@"properties.time"] doubleValue]];
                    NSNumber *eventLat = [NSNumber numberWithDouble:[[[eventDict valueForKeyPath:@"geometry.coordinates"] objectAtIndex:0] doubleValue]];
                    NSNumber *eventLong =[NSNumber numberWithDouble:[[[eventDict valueForKeyPath:@"geometry.coordinates"] objectAtIndex:1] doubleValue]];
                    NSNumber *eventMagnitude = [NSNumber numberWithFloat:[[eventDict valueForKeyPath:@"properties.mag"] floatValue]];
                    NSString *eventWebPath = [@"http://earthquake.usgs.gov" stringByAppendingPathComponent:[eventDict valueForKeyPath:@"properties.url"]];
                    
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Earthquake class])];
                    [fetchRequest setFetchLimit:1];
                    NSPredicate *eventInfo = [NSPredicate predicateWithFormat:@"location = %@ AND date = %@",
                                              eventLocation,
                                              eventDate];
                    [fetchRequest setPredicate:eventInfo];
                    NSError *fetchError=nil;
                    NSArray *existingEventsMatchingThisOne = [context executeFetchRequest:fetchRequest error:&fetchError];
                    if (existingEventsMatchingThisOne==nil) {
                        NSLog(@"Error checking for existing record: %@",[fetchError localizedDescription]);
                    } else if ([existingEventsMatchingThisOne count]==0) {

                        //Didn't find one already, make a new one
                        NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Earthquake class]) inManagedObjectContext:context];
                        
                        [newManagedObject setValue:eventLocation forKey:@"location"];
                        [newManagedObject setValue:eventDate forKey:@"date"]; 
                        [newManagedObject setValue:eventLat forKey:@"latitude"];
                        [newManagedObject setValue:eventLong forKey:@"longitude"];
                        [newManagedObject setValue:eventMagnitude forKey:@"magnitude"];
                        [newManagedObject setValue:eventWebPath forKey:@"webLinkToUSGS"];
                    }

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
    [self finish];
}

@end

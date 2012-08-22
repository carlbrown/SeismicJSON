//
//  EarthquakeFetchOperation.m
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import "EarthquakeFetchOperation.h"
#import "Earthquake.h"
#import "NotificationOrParentContext.h"

@implementation EarthquakeFetchOperation
@synthesize mainContext = _mainContext;

-(void) main {
    if (!_mainContext) {
        NSLog(@"Cannot start without a Primary Managed Object Context");
        return;
    }

    [super main];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([self isCancelled]) {
        [self finish];
        return;
    }
    
    if (self.response.statusCode==200) {
        
        NSError *error=nil;
        
        
        id objectFromJSON = [NSJSONSerialization JSONObjectWithData:self.fetchedData options:0 error:&error];
        if (objectFromJSON) {
#if kUSE_NSNOTIFICATIONS_FOR_CONTEXT_MERGE
                NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
                [context setPersistentStoreCoordinator:self.mainContext.persistentStoreCoordinator];
#else
            NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
                [context setParentContext:[self mainContext]];
#endif
            
            NSDictionary *jsonDict = (NSDictionary *) objectFromJSON;
            
            if (jsonDict) {
                
                NSArray *events = [jsonDict objectForKey:@"features"];
                
                if (events) {
                    
                    for (NSDictionary *eventDict in events) {
                        
                        NSString *eventLocation = [eventDict valueForKeyPath:@"properties.place"];
                        NSDate *eventDate = [NSDate dateWithTimeIntervalSince1970:[[eventDict valueForKeyPath:@"properties.time"] doubleValue]];
                        NSNumber *eventLong = [NSNumber numberWithDouble:[[[eventDict valueForKeyPath:@"geometry.coordinates"] objectAtIndex:0] doubleValue]];
                        NSNumber *eventLat =[NSNumber numberWithDouble:[[[eventDict valueForKeyPath:@"geometry.coordinates"] objectAtIndex:1] doubleValue]];
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
#if kUSE_PARENT_CONTEXTS_FOR_CONTEXT_MERGE
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            NSError *error = nil;
                            if (![self.mainContext save:&error]) {
                                // Replace this implementation with code to handle the error appropriately.
                                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
                                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                abort();
                            }
                        });
#endif
                }
            }
        }
    }
    [self finish];
}

@end

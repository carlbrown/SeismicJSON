//
//  MasterViewController.m
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "Earthquake.h"
#import "EarthQuakeTableViewCell.h"
#import "Earthquake+ThumbnailURL.h"
#import "ActivityIndicatingImageView.h"
#import "NotificationOrParentContext.h"

@interface MasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@end

@implementation MasterViewController
@synthesize tableView = _tableView;
@synthesize filterBar = _filterBar;
@synthesize detailViewController = _detailViewController;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext = _managedObjectContext;

@synthesize dateFormatter = _dateFormatter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"SeismicJSON", @"SeismicJSON");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
        }
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showSelectorActionSheet:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.dateFormatter=[[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#if kUSE_NSNOTIFICATIONS_FOR_CONTEXT_MERGE && kNSNOTIFICATIONS_HANDLED_IN_VIEWCONTROLLER
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changesSaved:) name:NSManagedObjectContextDidSaveNotification
                                               object:nil];
#endif
}

#if kUSE_NSNOTIFICATIONS_FOR_CONTEXT_MERGE && kNSNOTIFICATIONS_HANDLED_IN_VIEWCONTROLLER
- (void)changesSaved:(NSNotification *)notification {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self changesSaved:notification];
        });
        return;
    }
    if ([notification object] != self.managedObjectContext) {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    }
}
#endif

-(void) viewWillDisappear:(BOOL)animated {
#if kUSE_NSNOTIFICATIONS_FOR_CONTEXT_MERGE && kNSNOTIFICATIONS_HANDLED_IN_VIEWCONTROLLER

        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
#endif
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void) showSelectorActionSheet:(id) sender {
    NSArray *timeFrames = [[NetworkManager sharedManager] availableTimeFrames];
    if (!timeFrames) {
        return;
    }
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Pick TimeFrame" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *buttonTitle in timeFrames) {
        [actionsheet addButtonWithTitle:buttonTitle];
    }
    //Don't put a cancel button on the iPad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSInteger cancelButtonID = [actionsheet addButtonWithTitle:@"Cancel"];
        [actionsheet setCancelButtonIndex:cancelButtonID];
    }
    [actionsheet showInView:self.view];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex < 0) {
        //iPad Cancel
        return;
    }
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
        return;
    }
    NSString *title = [actionSheet title];
    if ([title isEqualToString:@"Pick TimeFrame"]) {
        NSArray *significanceFilters = [[NetworkManager sharedManager] significanceFiltersForTimeFrame:[actionSheet buttonTitleAtIndex:buttonIndex]];
        if (!significanceFilters) {
            return;
        }
        //launch the next actionsheet
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:[actionSheet buttonTitleAtIndex:buttonIndex] delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        for (NSString *buttonTitle in significanceFilters) {
            [actionsheet addButtonWithTitle:buttonTitle];
        }
        //Don't put a cancel button on the iPad
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            NSInteger cancelButtonID = [actionsheet addButtonWithTitle:@"Cancel"];
            [actionsheet setCancelButtonIndex:cancelButtonID];
        }
        [actionsheet showInView:self.view];
    } else {
        //launch the correct url
        NSString *relativeURL = [[NetworkManager sharedManager] relativeJSONURLForTimeFrame:title andSignificance:[actionSheet buttonTitleAtIndex:buttonIndex]];
        if (!relativeURL) {
            return;
        }
        [[NetworkManager sharedManager] queuePageFetchForRelativePath:relativeURL];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EarthQuakeTableViewCell";
    
    [tableView registerNib:[UINib nibWithNibName:@"EarthQuakeTableViewCell" bundle:nil] forCellReuseIdentifier:CellIdentifier];
    
    EarthQuakeTableViewCell *cell = (EarthQuakeTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController) {
	        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil];
	    }
        self.detailViewController.detailItem = (Earthquake *) object;
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    } else {
        self.detailViewController.detailItem = (Earthquake *) object;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77.0f;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Earthquake" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSString *sortKey = [[self.filterBar titleForSegmentAtIndex:[self.filterBar selectedSegmentIndex]] lowercaseString];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(EarthQuakeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Earthquake *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.locationLabel.text = [object location];
    cell.magnitudeLabel.text = [[object magnitude] description];
    cell.dateLabel.text = [self.dateFormatter stringFromDate:[object date]];
    [cell.globeThumbnailImageView setImageFileName:[object thumbnailFilenameString]];
}

- (void)viewDidUnload {
    [self setFilterBar:nil];
    [self setTableView:nil];
    [super viewDidUnload];
}
- (IBAction)filterDidChange:(id)sender {
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController=nil;
    [self.tableView reloadData];
}
@end

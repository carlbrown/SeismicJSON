//
//  DetailViewController.m
//  SeismicJSON
//
//  Created by Carl Brown on 8/21/12.
//  Copyright (c) 2012 PDAgent, LLC. Released under MIT license ( http://opensource.org/licenses/MIT ).
//

#import "DetailViewController.h"
#import "Earthquake.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item
@synthesize magnitudeLabel;
@synthesize locationLabel;
@synthesize latitudeLabel;
@synthesize longitudeLabel;
@synthesize dateLabel;
@synthesize urlLabel;

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        [self.dateLabel setText:[NSString stringWithFormat:@"Date: %@",self.detailItem.date]];
        [self.magnitudeLabel setText:[NSString stringWithFormat:@"Magnitude: %@",self.detailItem.magnitude]];
        [self.locationLabel setText:[NSString stringWithFormat:@"Location: %@",self.detailItem.location]];
        [self.latitudeLabel setText:[NSString stringWithFormat:@"Latitude: %@",self.detailItem.latitude]];
        [self.longitudeLabel setText:[NSString stringWithFormat:@"Longitude: %@",self.detailItem.longitude]];
        [self.urlLabel setText:[NSString stringWithFormat:@"URL: %@",self.detailItem.webLinkToUSGS]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"SeismicJSON", @"SeismicJSON");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)viewDidUnload {
    [self setMagnitudeLabel:nil];
    [self setLocationLabel:nil];
    [self setLatitudeLabel:nil];
    [self setLongitudeLabel:nil];
    [self setDateLabel:nil];
    [self setUrlLabel:nil];
    [super viewDidUnload];
}
@end

//
//  AroundFetchDetailViewController.m
//  AroundFetch
//
//  Copyright (c) 2014 Newton Japan. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "AroundFetchDetailViewController.h"

@interface AroundFetchDetailViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSDictionary		*detailItem;
@property (strong, nonatomic) NSMutableArray	*locationItems;
@end

@implementation AroundFetchDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(NSDictionary *)newDetailItem withRoute:(NSMutableArray*)locationItems
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
    }
    if (_locationItems != locationItems) {
        _locationItems = locationItems;
    }

	[self configureView];
}

- (void)configureView
{
	if (_detailItem) {
		NSString *name = [_detailItem valueForKey:@"name"];
		NSString *address = [_detailItem valueForKey:@"address"];
		NSString *tel = [_detailItem valueForKey:@"tel"];
		NSString *weburl = [_detailItem valueForKey:@"url"];
		NSString *descriptionStr = [NSString stringWithFormat:@"%@\n%@\nTEL:%@\n%@", name, address, tel, weburl];
		_textView.text = descriptionStr;

		NSString *latitude = [_detailItem valueForKeyPath:@"coordinates.latitude"];
		NSString *longitude = [_detailItem valueForKeyPath:@"coordinates.longitude"];
		MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
		CLLocationCoordinate2D loc = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
		annotation.coordinate = loc;
		annotation.title = name;
		annotation.subtitle = address;

		[_mapView addAnnotation:annotation];
		[_mapView showAnnotations:[_mapView annotations] animated:YES];
	}

	if(_locationItems) {
		// 地図上の軌跡を更新する
		[_mapView removeOverlays:[_mapView overlays]];

		int numberOfSteps = (int)_locationItems.count;
		
		CLLocationCoordinate2D coordinates[numberOfSteps];
		for (int index = 0; index < numberOfSteps; index++) {
			CLLocation *location = [_locationItems objectAtIndex:index];
			CLLocationCoordinate2D coordinate = location.coordinate;
			coordinates[index] = coordinate;
        }
		
		MKPolyline *polyLine = [MKPolyline polylineWithCoordinates:coordinates count:numberOfSteps];
		[_mapView addOverlay:polyLine level:MKOverlayLevelAboveRoads];
	}
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay {
	
	MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKPolyline*)overlay];
	
	renderer.lineWidth = 5.0;
	renderer.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
	
	return (MKOverlayRenderer*)renderer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_mapView.delegate = self;
	[self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end

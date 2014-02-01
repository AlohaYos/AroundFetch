//
//  AroundFetchMasterViewController.m
//  AroundFetch
//
//  Copyright (c) 2014 Newton Japan. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "AroundFetchMasterViewController.h"
#import "AroundFetchDetailViewController.h"

@interface AroundFetchMasterViewController ()
	@property (strong, nonatomic)	CLLocationManager	*locationManager;
	@property (strong, nonatomic)	NSMutableData		*jsonData;
	@property (strong, nonatomic)	NSMutableArray		*locationItems;
	@property (nonatomic)			BOOL				deferredLocationUpdates;
@end

@implementation AroundFetchMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	_locationItems = [NSMutableArray array];
	_deferredLocationUpdates = NO;
	
	_locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
	_locationManager.activityType = CLActivityTypeFitness;
	_locationManager.distanceFilter = kCLDistanceFilterNone;
	_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[_locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Location Job

-(void)locationManager:(CLLocationManager *)manager
	didUpdateLocations:(NSArray *)locations
{
	[self displayMessage:@"didUpdateLocations"];
	[_locationItems addObjectsFromArray:locations];
	
	if(!_deferredLocationUpdates) {
		CLLocationDistance	distance = 100.0;	// meter
		NSTimeInterval		time = 5.0;		// sec
	//	NSTimeInterval		time = 30.0;		// sec
		[_locationManager allowDeferredLocationUpdatesUntilTraveled:distance timeout:time];
		_deferredLocationUpdates = YES;
	}
}

-(void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
	[self displayMessage:@"didFinishDeferredUpdatesWithError"];
	_deferredLocationUpdates = NO;

	CLLocationCoordinate2D nowLoc = manager.location.coordinate;
	[self fetchOpenData:nowLoc];
}


-(void)displayMessage:(NSString*)msg
{
	NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
	NSString *outputDateFormatterStr = @"HH:mm:ss";
	[outputDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
	[outputDateFormatter setDateFormat:outputDateFormatterStr];
	NSString *outputDateStr = [outputDateFormatter stringFromDate:[NSDate date]];
	
	NSLog(@"%@ %@", outputDateStr, msg);
}

#pragma mark - Fetch Open data

-(void)fetchOpenData:(CLLocationCoordinate2D)location
{
	NSString *requestStr = [NSString stringWithFormat:@"https://infra-api.city.kanazawa.ishikawa.jp/v1/facilities/search.json?lang=ja&genre=1&count=15&geocode=%f,%f,50000", location.latitude, location.longitude];
	requestStr = @"https://infra-api.city.kanazawa.ishikawa.jp/v1/facilities/search.json?lang=ja&genre=1&count=15&geocode=36.561051,136.656633,1000";

	NSURL *url = [NSURL URLWithString:requestStr];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	
	[NSURLConnection connectionWithRequest:request delegate:self];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	
	_jsonData = [NSMutableData data];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	
	[_jsonData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
	
	NSError *error = nil;
	
	NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:_jsonData options:NSJSONReadingMutableContainers error:&error];
	
	NSArray *facilities = [jsonDic valueForKey:@"facilities"];
	for(NSDictionary *item in facilities) {
	//	NSString *latitude = [item valueForKeyPath:@"coordinates.latitude"];
	//	NSString *longitude = [item valueForKeyPath:@"coordinates.longitude"];
	//	NSString *name = [item valueForKey:@"name"];
	//	NSString *tel = [item valueForKey:@"tel"];
	}
	
	if(error){
		
	}
	
	[self.tableView reloadData];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(_jsonData) {
		NSError *error = nil;
		NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:_jsonData options:NSJSONReadingMutableContainers error:&error];
		NSArray *facilities = [jsonDic valueForKey:@"facilities"];
		return [facilities count];
	}
	else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	
	NSError *error = nil;
	NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:_jsonData options:NSJSONReadingMutableContainers error:&error];
	NSArray *facilities = [jsonDic valueForKey:@"facilities"];
	NSDictionary *item = [facilities objectAtIndex:indexPath.row];

	NSString *name = [item valueForKey:@"name"];
	NSString *address = [item valueForKey:@"address"];
	
	cell.textLabel.text = name;
	cell.detailTextLabel.text = address;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

		NSError *error = nil;
		NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:_jsonData options:NSJSONReadingMutableContainers error:&error];
		NSArray *facilities = [jsonDic valueForKey:@"facilities"];
		NSDictionary *item = [facilities objectAtIndex:indexPath.row];

        [[segue destinationViewController] setDetailItem:item withRoute:_locationItems];
    }
}

@end

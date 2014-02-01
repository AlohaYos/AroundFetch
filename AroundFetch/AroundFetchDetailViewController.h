//
//  AroundFetchDetailViewController.h
//  AroundFetch
//
//  Copyright (c) 2014 Newton Japan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AroundFetchDetailViewController : UIViewController <MKMapViewDelegate>

- (void)setDetailItem:(NSDictionary *)newDetailItem withRoute:(NSMutableArray*)locationItems;

@end

//
//  ViewController.h
//  TestProject
//
//  Created by vm mac on 28/06/2016.
//  Copyright © 2016 PytenLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface ViewController : UIViewController

+(NSArray *)groupFromJSON:(NSData *)objectNotation error:(NSError **) error;
-(void)receivedGroupsJSON:(NSData *)objectNotation;
-(void) fetchingGroupsFailedWithError:(NSError *)error;

@property (weak, nonatomic) id delegate;
@property(nonatomic, strong) IBOutlet UITableView *tableView;


-(void)searchGroupsAtCoordinate :(CLLocationCoordinate2D)coordinate;

@end





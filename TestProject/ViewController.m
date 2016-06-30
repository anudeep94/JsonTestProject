//
//  ViewController.m
//  TestProject
//
//  Created by vm mac on 28/06/2016.
//  Copyright © 2016 PytenLabs. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIKit.h>
#import "Group.h"
#import "DetailCell.h"

#define API_KEY @"5d11401a1335801321166722396f42"
#define PAGE_COUNT 20

#define lat 10.055433
#define longi 76.354878






@interface ViewController()
@property (weak, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

NSArray *_groups;


+(NSArray *)groupFromJSON:(NSData *)objectNotation error:(NSError **) error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    NSArray *results = [parsedObject valueForKey:@"results"];
    NSLog(@"Count %lu", (unsigned long)results.count);
    
    for (NSDictionary *groupDic in results) {
        Group *group = [[Group alloc] init];
        
        for (NSString *key in groupDic) {
            if ([group respondsToSelector:NSSelectorFromString(key)]) {
                
                NSString *newKey = key;
                if ([key isEqualToString:@"description"]) {
                    newKey = @"descript";
                }
                [group setValue:[groupDic valueForKey:key] forKey:newKey];
            }
        }
        
        [groups addObject:group];
    }
    
    return groups;
}

-(void)fetchGroupsAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self/*.communicator*/ searchGroupsAtCoordinate :coordinate];
}



-(void)receivedGroupsJSON:(NSData *)objectNotation
{
    NSError *error=nil;
    NSArray *groups=[ViewController groupFromJSON:objectNotation error:&error];
    
    if(error !=nil)
    {
        [self.delegate fetchingGroupsFailedWithError:error];
    }else{
        
        [self.delegate didReceiveGroups:groups];
    }
}

-(void) fetchingGroupsFailedWithError:(NSError *)error
{
    [self.delegate fetchingGroupsFailedWithError:error];
}

- (void)startFetchingGroups:(NSNotification *)notification
{
    [self.delegate fetchGroupsAtCoordinate:self.locationManager.location.coordinate];
}

-(void) searchGroupsAtCoordinate:(CLLocationCoordinate2D)coordinate

{
    
    NSString *urlAsString = [NSString stringWithFormat:@"https://api.meetup.com/2/groups?lat=%f&lon=%f&page=%d&key=%@", lat, longi, PAGE_COUNT, API_KEY];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
    NSLog(@"%@", urlAsString);
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self.delegate fetchingGroupsFailedWithError:error];
        } else {
            [self.delegate receivedGroupsJSON:data];
        }
    }];
}






- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    Group *group = _groups[indexPath.row];
    [cell.nameLabel setText:group.name];
    
    return cell;
}
- (void)didReceiveGroups:(NSArray *)groups
{
    _groups = groups;
    [self.tableView reloadData];
}


@end

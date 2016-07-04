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
#import <UIKit/UITableView.h>


#define API_KEY @"5d11401a1335801321166722396f42"
#define PAGE_COUNT 20

#define lat 10.055433
#define longi 76.354878


@interface ViewController() <UITableViewDataSource, UITableViewDelegate>
{
    __weak IBOutlet UILabel *Namelabel;
    NSArray *groups;
}

@property (weak, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *descript;
@property (weak, nonatomic) IBOutlet UILabel *who;
@property (weak, nonatomic) IBOutlet UILabel *location;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startFetchingGroups:)
                                                 name:@"kCLAuthorizationStatusAuthorized"
                                               object:nil];
    //notifies the Authorization like an popup message
    self.tableView.delegate= self;
    self.tableView.dataSource=self;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


+(NSArray *)groupFromJSON:(NSData *)objectNotation error:(NSError **) error
{
    NSError *localError = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:objectNotation options:0 error:&localError];//Converts the JSON content, make it readable for the compiler.
    
    if (localError != nil) {
        *error = localError;
        return nil;
    }
    
    NSMutableArray *groups = [[NSMutableArray alloc] init];//Modifiable Array
    
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
        // Maps to a dictionary according to the keys, the corresponding value will be referenced.
        [groups addObject:group];
    }
    
    return groups;
}

-(void)fetchGroupsAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self searchGroupsAtCoordinate :coordinate];
}



-(void)receivedGroupsJSON:(NSData *)objectNotation
{
    NSError *error=nil;
    NSArray *receivedGroups=[ViewController groupFromJSON:objectNotation error:&error];
    
    if(error !=nil)
    {
        [self fetchingGroupsFailedWithError:error];
    }else{
        
        [self didReceiveGroups:receivedGroups];
    }
}

-(void) fetchingGroupsFailedWithError:(NSError *)error
{
    [self fetchingGroupsFailedWithError:error];
}//fetches groups with erros.

- (void)startFetchingGroups:(NSNotification *)notification
{
    [self fetchGroupsAtCoordinate:self.locationManager.location.coordinate];
}//fetches groups

-(void) searchGroupsAtCoordinate:(CLLocationCoordinate2D)coordinate

{
    
    NSString *urlAsString = [NSString stringWithFormat:@"https://api.meetup.com/2/groups?lat=%f&lon=%f&page=%d&key=%@", lat, longi, PAGE_COUNT, API_KEY];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
    NSLog(@"%@", urlAsString);
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            [self fetchingGroupsFailedWithError:error];
        } else {
            [self receivedGroupsJSON:data];
        }
    }];
}//establishes a connection with the API


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return groups.count;//returns the count of no.of elements passed.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"  forIndexPath:indexPath];//Resizes the cell according to the registered identifier
    
    Group *group = groups[indexPath.row];
    [cell.nameLabel setText:group.name];//appends the retrived values to the label
    
    return cell;
}
- (void)didReceiveGroups:(NSArray *)receivedGroups
{
    dispatch_async(dispatch_get_main_queue(), ^{
        groups = receivedGroups;
        [self.tableView reloadData];
    });
    //Reloads New data into the the table view.
}


@end

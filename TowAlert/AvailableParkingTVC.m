//
//  AvailableParkingTVC.m
//  TowAlert
//
//  Created by Dalton on 3/6/16.
//  Copyright © 2016 Dalton. All rights reserved.
//

#import "AvailableParkingTVC.h"
#import "Appearance.h"
#import "AFNetworking.h"
#import "AFURLRequestSerialization.h"

@interface AvailableParkingTVC ()

@property (strong, nonatomic) NSArray *locationNames;
@property (strong, nonatomic) NSArray *locationAddresses;
@property (strong, nonatomic) NSArray *locationCities;
@property (strong, nonatomic) NSArray *locationState;
@property (strong, nonatomic) NSArray *locationZip;
@property (strong, nonatomic) NSString *currentLocation;

@end

@implementation AvailableParkingTVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"PARKING NEAR YOU";
    
    [Appearance initializeAppearanceDefaults];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self sendGetparkingRequest:self];

    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
        
    }
    
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    
    if (authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        
        [locationManager startUpdatingLocation];
        
    }
    
    CLLocation *loc = locationManager.location;
    // Reverse Geocoding
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            
            placemark = [placemarks lastObject];
            self.currentLocation = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",
                                   placemark.subThoroughfare, placemark.thoroughfare,
                                   placemark.locality, placemark.administrativeArea,
                                   placemark.postalCode];
            

        } else {
            NSLog(@"%@", error.debugDescription);
        }
    }];
    
}




#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.locationNames.count;
}


- (IBAction)doneTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.locationNames objectAtIndex:indexPath.row]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@", [self.locationAddresses objectAtIndex:indexPath.row], [self.locationCities objectAtIndex:indexPath.row], [self.locationState objectAtIndex:indexPath.row], [self.locationZip objectAtIndex:indexPath.row]];
    cell.imageView.image = [UIImage imageNamed:@"Pin"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    
    return cell;
}






-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // open maps app with location
    NSString *latlong = [NSString stringWithFormat:@"%@ %@ %@ %@", [self.locationAddresses objectAtIndex:indexPath.row], [self.locationCities objectAtIndex:indexPath.row], [self.locationState objectAtIndex:indexPath.row], [self.locationZip objectAtIndex:indexPath.row]];
    
    NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%@",
                     [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    
    NSLog(@"Button tapped");
    
}







- (void)sendGetparkingRequest:(id)sender
{
    // getParking (GET http://api.parkwhiz.com/search/)
    
    // Create manager
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    // Create request
    NSDictionary* URLParameters = @{
                                    @"key":@"70dd81f415df564362aaf878512899bc",
                                    @"destination":@"417 S 6th Street Boise Idaho",
                                    };
    NSMutableURLRequest* request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:@"https://api.parkwhiz.com/search/" parameters:URLParameters error:NULL];
    
    // Add Headers
    [request setValue:@"current_city=default; PLACES_LOCATION_BIAS=40.2393884%2C-111.6465705" forHTTPHeaderField:@"Cookie"];
    
    // Fetch Request
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
                                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                             NSLog(@"HTTP Response Status Code: %ld", [operation.response statusCode]);
                                                                             NSLog(@"HTTP Response Body: %@", responseObject);

                                                                                 if([responseObject isKindOfClass:[NSDictionary class]])
                                                                                 {
                                                                                     NSDictionary *results = responseObject;
                                                                                     
                                                                                     NSMutableArray *mutableLocationNames = [NSMutableArray arrayWithArray:self.locationNames];
                                                                                     NSArray *locations = [results objectForKey:@"parking_listings"];
                                                                                     
                                                                                     NSMutableArray *mutableLocationAddresses = [NSMutableArray arrayWithArray:self.locationAddresses];
                                                                                     
                                                                                     NSMutableArray *mutableCities = [NSMutableArray arrayWithArray:self.locationCities];
                                                                                     
                                                                                     NSMutableArray *mutableStates = [NSMutableArray arrayWithArray:self.locationState];
                                                                                     
                                                                                     NSMutableArray *mutableZip = [NSMutableArray arrayWithArray:self.locationZip];
                                                                                     
                                                                                     for (NSDictionary *dict in locations) {
                                                                                         
                                                                                         [mutableLocationNames addObject:[dict objectForKey:@"location_name"]];
                                                                                         self.locationNames = mutableLocationNames;
                                                                                         
                                                                                         [mutableLocationAddresses addObject:[dict objectForKey:@"address"]];
                                                                                         self.locationAddresses = mutableLocationAddresses;
                                                                                         
                                                                                         [mutableCities addObject:[dict objectForKey:@"city"]];
                                                                                         self.locationCities = mutableCities;
                                                                                         
                                                                                         [mutableStates addObject:[dict objectForKey:@"state"]];
                                                                                         self.locationState = mutableStates;
                                                                                         
                                                                                         [mutableZip addObject:[dict objectForKey:@"zip"]];
                                                                                         self.locationZip = mutableZip;
                                                                                         
                                                                                         [self.tableView reloadData];
                                                                                         
                                                                                         if (self.locationNames.count == 0) {
                                                                                             // alert controller
                                                                                             UIAlertController * alert=   [UIAlertController
                                                                                                                           alertControllerWithTitle:@"Oops"
                                                                                                                           message:@"We could not find any parking near you"
                                                                                                                           preferredStyle:UIAlertControllerStyleAlert];
                                                                                             
                                                                                             UIAlertAction* ok = [UIAlertAction
                                                                                                                  actionWithTitle:@"OK"
                                                                                                                  style:UIAlertActionStyleDefault
                                                                                                                  handler:^(UIAlertAction * action)
                                                                                                                  {
                                                                                                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                                                                                                      
                                                                                                                  }];
                                                                                             
                                                                                             [alert addAction:ok];
                                                                                             
                                                                                             [self presentViewController:alert animated:YES completion:nil];
                                                                                         }
                                                                                     }
                           
                                                                                 }
                                                                                 else
                                                                                 {
                                                                                     NSLog(@"outermost response object is not a dictionary");
                                                                                 }
                                                                             
                                                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                             NSLog(@"HTTP Request failed: %@", error);
                                                                         }];
    
    [manager.operationQueue addOperation:operation];
}







/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

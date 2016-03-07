//
//  AvailableParkingTVC.h
//  TowAlert
//
//  Created by Dalton on 3/6/16.
//  Copyright © 2016 Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface AvailableParkingTVC : UITableViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate> {
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@end

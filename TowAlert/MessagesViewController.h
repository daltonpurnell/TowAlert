//
//  MessagesViewController.h
//  TowAlert
//
//  Created by Dalton on 3/4/16.
//  Copyright © 2016 Dalton. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import "AvailableParkingTVC.h"
@import CoreLocation;

@interface MessagesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UIScrollViewDelegate> {
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}
@property (weak, nonatomic) IBOutlet UINavigationItem *logInLogOutButton;

@end

//
//  MessagesViewController.m
//  TowAlert
//
//  Created by Dalton on 3/4/16.
//  Copyright © 2016 Dalton. All rights reserved.
//

#import "MessagesViewController.h"
#import <JSQMessagesViewController/JSQMessages.h>
#import "BuddySDK/Buddy.h"
#import "CustomAlertCel.h"
#import "Appearance.h"
#import "UIView+Toast.h"
#import "AFNetworking.h"
#import "AFURLRequestSerialization.h"



@interface MessagesViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *towTruckSightingButton;
@property (weak, nonatomic) IBOutlet UIButton *carGettingTowedButton;
@property (strong, nonatomic) UIImage *pickedImage;
@property (nonatomic, strong) UIPopoverController *popOver;

@property (strong, nonatomic) NSArray *alerts;
@property (strong, nonatomic) NSArray *recipients;
@property (strong, nonatomic) NSArray *recipientEmails;

@property (strong, nonatomic) NSString *locationString;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (weak, nonatomic) IBOutlet UIButton *whereToParkButton;



@end

@implementation MessagesViewController

- (void)viewDidLoad {
    
    NSString *savedUsername = [[NSUserDefaults standardUserDefaults]
                            stringForKey:@"username"];
    
    if (savedUsername == nil) {
        
        self.logInLogOutButton.title = @"Log In";
        [self authorizationNeedsUserLogin];
        
    } else {
        
        self.logInLogOutButton.title = @"Log Out";
        
    }
    
    
    self.title = @"TOW ALERT";
    
    
    geocoder = [[CLGeocoder alloc] init];
    
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

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [Appearance initializeAppearanceDefaults];
    
    self.towTruckSightingButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BLUE"]];
    self.towTruckSightingButton.clipsToBounds = YES;
    self.towTruckSightingButton.layer.cornerRadius = 10;
    self.towTruckSightingButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.towTruckSightingButton.layer.shadowOffset = CGSizeMake(1, 2);
    self.towTruckSightingButton.layer.shadowOpacity = 0.5;
    self.towTruckSightingButton.clipsToBounds = NO;
    self.towTruckSightingButton.layer.shadowRadius = 2.0;

    
    self.carGettingTowedButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BLUE"]];
    self.carGettingTowedButton.clipsToBounds = YES;
    self.carGettingTowedButton.layer.cornerRadius = 10;
    self.carGettingTowedButton.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.carGettingTowedButton.layer.shadowOffset = CGSizeMake(1, 2);
    self.carGettingTowedButton.layer.shadowOpacity = 0.5;
    self.carGettingTowedButton.clipsToBounds = NO;
    self.carGettingTowedButton.layer.shadowRadius = 2.0;
    
    
    self.whereToParkButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"whereToPark"]];
    
    
    [self loadAlertsFromBuddy];
    
    
    CLLocation *loc = locationManager.location;
    // Reverse Geocoding
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            
            placemark = [placemarks lastObject];
            self.locationString = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",
                                   placemark.subThoroughfare, placemark.thoroughfare,
                                   placemark.locality, placemark.administrativeArea,
                                   placemark.postalCode];
            
            self.longitude = loc.coordinate.longitude;
            self.latitude = loc.coordinate.latitude;
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    }];
    
    self.whereToParkButton.hidden = YES;
    self.carGettingTowedButton.hidden = YES;
    self.towTruckSightingButton.hidden = YES;
    
    [self performSelector:@selector(animateButton) withObject:nil afterDelay:3.0];

    [self performSelector:@selector(animateBottomButton1) withObject:nil afterDelay:1.0];
    
    [self performSelector:@selector(animateBottomButton2) withObject:nil afterDelay:1.0];

    
    
}



-(void)authorizationNeedsUserLogin
{

    [self performSegueWithIdentifier:@"showLogin" sender:self];
    
}



#pragma mark - tableview delegate/datasource methods
-(CustomAlertCel *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CustomAlertCel *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    // Configure the cell...
    BPPicture *picture = [self.alerts objectAtIndex:indexPath.row];
    [Buddy GET:[NSString stringWithFormat:@"pictures/%@/file", picture.id] parameters:nil class:[BPFile class] callback:^(id obj, NSError *error) {
        
        if(error==nil)
        {
            BPFile *file = (BPFile*)obj;
            
            UIImage* image = [UIImage imageWithData:file.fileData];
            [cell.imageView setImage:image];
            
            cell.carTowedOrTruckSpotted.text = picture.title;
            
            cell.locationLabel.text = picture.tag;
            
            cell.timeStampLabel.text = picture.caption;
            
        }
        
    }];
    
    return cell;
}




-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 140;
}




-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.alerts.count;
}





- (IBAction)towTruckSightingButtonTapped:(id)sender {
    
    // create a truck spotted file
    
    // convert uiimage to bpfile
    BPFile *file = [[BPFile alloc] init];
    file.contentType = @"image/png";
    file.fileData = UIImagePNGRepresentation([UIImage imageNamed:@"TowTruck"]);
    
    
    // convert nsdate to string
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yyy HH:mm a"];
    NSDate *date = [NSDate date];
    NSString *dateString = [dateFormatter stringFromDate:date];

            
            // post picture
            NSDictionary *params = @{
                                     @"data": file,
                                     @"location": BPCoordinateMake(self.latitude, self.longitude),
                                     @"tag": self.locationString,
                                     @"caption": dateString,
                                     @"readPermissions": @"App",
                                     @"writePermissions": @"App",
                                     @"title": @"Tow truck spotted near:"
                                     };
            
            [Buddy POST:@"/pictures" parameters:params class:[BPPicture class] callback:^(id obj, NSError *error) {
                // Your callback code here
                if (!error) {
                    NSLog(@"Success!");
                    
                    [self loadUsersFromBuddy];
                    [self loadAlertsFromBuddy];
                    
                } else {
                    
                    NSLog(@"ERROR: %@", error);
                }
                
                
            }];
    
}




- (IBAction)carGettingTowedButtonTapped:(id)sender {
    
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    
    // if device is an ipad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cameraRollAction = [UIAlertAction actionWithTitle:@"From Library" style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * action) {
                                                                     
                                                                     
                                                                     UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                                                                     self.popOver =[[UIPopoverController alloc]
                                                                                    initWithContentViewController:imagePicker];
                                                                     imagePicker.delegate = self;
                                                                     [self.popOver setPopoverContentSize:CGSizeMake(400, 600) animated:YES];
                                                                     
                                                                     [self.popOver presentPopoverFromRect:self.carGettingTowedButton.frame
                                                                                                   inView:self.view
                                                                                 permittedArrowDirections:UIPopoverArrowDirectionUnknown
                                                                                                 animated:YES];
                                                                     
                                                                 }];
        
        [alert addAction:cameraRollAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        
        [alert addAction:cancelAction];
        
        
        
        UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:@"Take Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeCamera] == YES) {
                
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                self.popOver =[[UIPopoverController alloc]
                               initWithContentViewController:imagePicker];
                
                imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                imagePicker.allowsEditing = YES;
                imagePicker.delegate = self;
                
                
                [self.popOver setPopoverContentSize:CGSizeMake(400, 600) animated:YES];
                
                [self.popOver presentPopoverFromRect:self.carGettingTowedButton.frame
                                              inView:self.view
                            permittedArrowDirections:UIPopoverArrowDirectionAny
                                            animated:YES];
                
                
            } else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Camera Not Available on Device" message:@"This device does not have a camera option. Please choose photo from library." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                }];
                
                [alert addAction:dismissAction];
                
                [self presentViewController:alertController animated:YES completion:nil];
                
            }
            
            
            
        }];
        
        [alert addAction:takePictureAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
        
        
        // if it's a phone
    } else {
        
        UIAlertController *photoActionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            
        }];
        
        [photoActionSheet addAction:cancelAction];
        
        UIAlertAction *cameraRollAction = [UIAlertAction actionWithTitle:@"From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            imagePicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:imagePicker animated:YES completion:nil];
            
        }];
        
        [photoActionSheet addAction:cameraRollAction];
        
        
        
        UIAlertAction *takePictureAction = [UIAlertAction actionWithTitle:@"Take Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeCamera] == YES) {
                
                
                imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
                imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                imagePicker.allowsEditing = YES;
                
                
                [self presentViewController:imagePicker animated:YES completion:nil];
                
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera Not Available on Device" message:@"This device does not have a camera option. Please choose photo from library." preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                }];
                
                [alert addAction:dismissAction];
                
                [self presentViewController:alert animated:YES completion:nil];
                
            }
        }];
        
        [photoActionSheet addAction:takePictureAction];
        
        
        [self presentViewController:photoActionSheet animated:YES completion:nil];
        
    }
}





#pragma mark - image picker delegate methods

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        [self.popOver dismissPopoverAnimated:YES];
        
        self.pickedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        NSLog(@"didfinishpicking (ipad) got called");
    }else {
        
        [picker dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    self.pickedImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSLog(@" didfinishpicking got called");
    
    // compress image
    UIImage *compressedImage = [self imageWithImage:self.pickedImage scaledToSize:CGSizeMake(400, 400)];
    
    // convert uiimage to bpfile
    BPFile *file = [[BPFile alloc] init];
    file.contentType = @"image/png";
    file.fileData = UIImagePNGRepresentation(compressedImage);
    
    
    // convert nsdate to string
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yyy HH:mm a"];
    NSDate *date = [NSDate date];
    NSString *dateString = [dateFormatter stringFromDate:date];

            
            // post picture
            NSDictionary *params = @{
                                     @"data": file,
                                     @"location": BPCoordinateMake(self.latitude, self.longitude),
                                     @"tag": self.locationString,
                                     @"caption": dateString,
                                     @"readPermissions": @"App",
                                     @"writePermissions": @"App",
                                     @"title": @"Car being towed near:"
                                     };
            
            [Buddy POST:@"/pictures" parameters:params class:[BPPicture class] callback:^(id obj, NSError *error) {
                // Your callback code here
                if (!error) {
                    NSLog(@"Success!");
                    
                    [self loadUsersFromBuddyForCarTow];
                    [self loadAlertsFromBuddy];
                    
                } else {
                    
                    NSLog(@"ERROR: %@", error);
                }
                
                
            }];

}




-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        [self.popOver dismissPopoverAnimated:YES];
        
    }else {
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    
    
    NSLog(@"diddismisspopver got called");
    
}




#pragma mark - my custom methods

- (IBAction)logInOutButtonTapped:(id)sender {
    
    
    NSString *savedUsername = [[NSUserDefaults standardUserDefaults]
                               stringForKey:@"username"];
    
    if (savedUsername == nil) {
        
        
        // log in vc
        [self performSegueWithIdentifier:@"showLogin" sender:self];
        
        
    } else {
        
        // log out
            [Buddy logoutUser:^(NSError *error) {
                // Perform some action on logout
                NSLog(@"Success! Logged out");
                [self performSegueWithIdentifier:@"showLogin" sender:self];
                
            }];
        
        
    }
    
}


- (IBAction)whereToParkButtonTapped:(id)sender {
    
    [self performSegueWithIdentifier:@"showParking" sender:self];
    
}





-(void) loadAlertsFromBuddy {
    
    // load pictures from Buddy
    [Buddy GET:@"/pictures" parameters:nil class:[BPPageResults class] callback:^(id obj, NSError *error) {
        
        if (!error) {
            // Your callback code here
            BPPageResults *searchResults = (BPPageResults*)obj;
            self.alerts = [searchResults convertPageResultsToType:[BPPicture class]];
            [self.tableView reloadData];
            NSLog(@"ALERTS: %@", self.alerts);
            
        } else {
            
            NSLog(@"ERROR: %@", error);
        }
    }];
}




- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}





-(void) loadUsersFromBuddy {
    
    NSDictionary *params = @{
//                             @"locationRange": BPCoordinateRangeMake(self.latitude, self.longitude, 2500)
                             };
    
    [Buddy GET:@"/users" parameters:params class:[BPPageResults class] callback:^(id obj, NSError *error) {
        // Your callback code here
        
        if (!error) {
            BPPageResults *searchResults = (BPPageResults*)obj;
            self.recipients = [searchResults convertPageResultsToType:[BPUser class]];
//            NSLog(@"RECIPIENTS: %@", self.recipients);

            NSMutableArray *mutableRecipientEmails = [NSMutableArray arrayWithArray:self.recipientEmails];
            for (BPUser *user in self.recipients) {

                [mutableRecipientEmails addObject:user.id];
                self.recipientEmails = mutableRecipientEmails;
                NSLog(@"RECIPIENT USER IDS: %@", self.recipientEmails);
                
                NSDictionary *params = @{
                                         @"pushType": @"Alert",
                                         @"message": self.locationString,
                                         @"title": @"Tow truck spotted!",
                                         @"recipients": self.recipientEmails
                                         };
                
                [Buddy POST:@"/notifications" parameters:params class:[NSDictionary class] callback:^(id obj, NSError *error) {
                    // Your callback code here
                    [self.view makeToast:@"Users in the area have been notified."
                                duration:3.0
                                position:CSToastPositionTop];
                }];
                
                
            }
            
        } else {
            
            NSLog(@"ERROR: %@", error);
            
        }
    }];
}




-(void) loadUsersFromBuddyForCarTow {
    
    NSDictionary *params = @{
//                             @"locationRange": BPCoordinateRangeMake(self.latitude, self.longitude, 2500)
                             };
    
    [Buddy GET:@"/users" parameters:params class:[BPPageResults class] callback:^(id obj, NSError *error) {
        // Your callback code here
        
        if (!error) {
            BPPageResults *searchResults = (BPPageResults*)obj;
            self.recipients = [searchResults convertPageResultsToType:[BPUser class]];
            //            NSLog(@"RECIPIENTS: %@", self.recipients);
            
            NSMutableArray *mutableRecipientEmails = [NSMutableArray arrayWithArray:self.recipientEmails];
            for (BPUser *user in self.recipients) {
                
                [mutableRecipientEmails addObject:user.id];
                self.recipientEmails = mutableRecipientEmails;
                NSLog(@"RECIPIENT USER IDS: %@", self.recipientEmails);
                
                NSDictionary *params = @{
                                         @"pushType": @"Alert",
                                         @"message": self.locationString,
                                         @"title": @"Car being towed near:",
                                         @"recipients": self.recipientEmails
                                         };
                
                [Buddy POST:@"/notifications" parameters:params class:[NSDictionary class] callback:^(id obj, NSError *error) {
                    // Your callback code here
                    [self.view makeToast:@"Users in the area have been notified."
                                duration:3.0
                                position:CSToastPositionTop];
                }];
                
                
            }
            
        } else {
            
            NSLog(@"ERROR: %@", error);
            
        }
    }];
}



#pragma mark - button animation

-(void)animateButton {
    
    // button animations
    // 1
    
    CGRect originalCellFrame = self.whereToParkButton.frame;
    self.whereToParkButton.hidden = NO;
    
    // 2
    self.whereToParkButton.frame = CGRectMake(self.tableView.frame.size.width + originalCellFrame.size.width,
                                              originalCellFrame.origin.y,
                                              originalCellFrame.size.width,
                                              originalCellFrame.size.height);
    // 3
    [UIView animateWithDuration:0.75
                          delay:0.25
         usingSpringWithDamping:0.8
          initialSpringVelocity:2.0
                        options: UIViewAnimationOptionCurveLinear
     // 4
                     animations:^{
                         self.whereToParkButton.frame = originalCellFrame;
                     }
                     completion:^(BOOL finished){
                     }];
    
    
    
}






-(void)animateBottomButton1 {
    
    // button animations
    // 1
    
    CGRect originalCellFrame = self.carGettingTowedButton.frame;
    self.carGettingTowedButton.hidden = NO;
    
    // 2
    self.carGettingTowedButton.frame = CGRectMake(originalCellFrame.origin.x,
                                              self.tableView.frame.size.height + originalCellFrame.size.height,
                                              originalCellFrame.size.width,
                                              originalCellFrame.size.height);
    // 3
    [UIView animateWithDuration:0.75
                          delay:0.25
         usingSpringWithDamping:0.8
          initialSpringVelocity:2.0
                        options: UIViewAnimationOptionCurveLinear
     // 4
                     animations:^{
                         self.carGettingTowedButton.frame = originalCellFrame;
                     }
                     completion:^(BOOL finished){
                     }];
}



-(void)animateBottomButton2 {
    
    // button animations
    // 1
    
    CGRect originalCellFrame = self.towTruckSightingButton.frame;
    self.towTruckSightingButton.hidden = NO;
    
    // 2
    self.towTruckSightingButton.frame = CGRectMake(originalCellFrame.origin.x,
                                                  self.tableView.frame.size.height + originalCellFrame.size.height,
                                                  originalCellFrame.size.width,
                                                  originalCellFrame.size.height);
    // 3
    [UIView animateWithDuration:0.75
                          delay:0.25
         usingSpringWithDamping:0.8
          initialSpringVelocity:2.0
                        options: UIViewAnimationOptionCurveLinear
     // 4
                     animations:^{
                         self.towTruckSightingButton.frame = originalCellFrame;
                         
                     }
                     completion:^(BOOL finished){
                     }];
}

-(void)hideButtonsAnimated {
    
    
    // where to park button
    CGRect newFrame = CGRectMake(self.whereToParkButton.frame.origin.x + self.whereToParkButton.frame.size.width, self.whereToParkButton.frame.origin.y, self.whereToParkButton.frame.size.width, self.whereToParkButton.frame.size.height);
    
    [UIView animateWithDuration:0.75f
                          delay:0.0f
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.whereToParkButton setFrame:newFrame];
                         self.whereToParkButton.hidden = YES;
                     }
                     completion:nil];
    
    // tow truck button
    CGRect newFrame1 = CGRectMake(self.towTruckSightingButton.frame.origin.x, self.towTruckSightingButton.frame.origin.y + self.towTruckSightingButton.frame.size.height + 30, self.towTruckSightingButton.frame.size.width, self.towTruckSightingButton.frame.size.height);
    
    [UIView animateWithDuration:0.75f
                          delay:0.0f
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.towTruckSightingButton setFrame:newFrame1];
                         self.towTruckSightingButton.hidden = YES;
                     }
                     completion:nil];
    
    
    // car being towed button
    CGRect newFrame2 = CGRectMake(self.carGettingTowedButton.frame.origin.x, self.carGettingTowedButton.frame.origin.y + self.carGettingTowedButton.frame.size.height + 30, self.carGettingTowedButton.frame.size.width, self.carGettingTowedButton.frame.size.height);
    
    [UIView animateWithDuration:0.75f
                          delay:0.0f
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         [self.carGettingTowedButton setFrame:newFrame2];
                         self.carGettingTowedButton.hidden = YES;
                     }
                     completion:nil];
    
    
    
}






#pragma mark - scroll view delegate method


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    [self hideButtonsAnimated];
    
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self animateButton];
    [self animateBottomButton1];
    [self animateBottomButton2];
}


#pragma mark - cllocation delegate methods
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//}


@end

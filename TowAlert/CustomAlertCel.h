//
//  CustomAlertCel.h
//  TowAlert
//
//  Created by Dalton on 3/4/16.
//  Copyright © 2016 Dalton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomAlertCel : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *backImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *carTowedOrTruckSpotted;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

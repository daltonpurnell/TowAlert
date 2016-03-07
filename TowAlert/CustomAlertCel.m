//
//  CustomAlertCel.m
//  TowAlert
//
//  Created by Dalton on 3/4/16.
//  Copyright © 2016 Dalton. All rights reserved.
//

#import "CustomAlertCel.h"
#import "Appearance.h"
#import "BuddySDK/Buddy.h"
#import "EXPhotoViewer.h"


@implementation CustomAlertCel
@synthesize imageView;

- (void)awakeFromNib {
    // Initialization code
}

-(void)layoutSubviews {
    self.backImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bluegray"]];
    self.backImageView.clipsToBounds = YES;
    self.backImageView.layer.cornerRadius = 3;
    self.backImageView.layer.shadowColor = [UIColor colorWithRed:85/255 green:109/255 blue:119/255 alpha:1].CGColor;
    self.backImageView.layer.shadowOffset = CGSizeMake(2, 3);
    self.backImageView.layer.shadowOpacity = 1;
    self.backImageView.clipsToBounds = NO;
    self.backImageView.layer.shadowRadius = 2.0;
    self.backImageView.alpha = 0.2;
    
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = 3;
    
    
    UIView *userImageView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x + self.frame.size.width - 46, self.frame.origin.y + self.frame.size.height - 46, 38, 38)];
    
    userImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"User"]];
    userImageView.clipsToBounds = YES;
    userImageView.layer.cornerRadius = self.frame.size.height / 2;
    userImageView.layer.borderColor = [UIColor colorWithRed:79/255 green:100/255 blue:110/255 alpha:1].CGColor;
    userImageView.layer.borderWidth = 2;
    
    [self addSubview:userImageView];

    
    [Appearance initializeAppearanceDefaults];

    
}
- (IBAction)imageTapped:(id)sender {
    
    
    [EXPhotoViewer showImageFrom:self.imageView];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

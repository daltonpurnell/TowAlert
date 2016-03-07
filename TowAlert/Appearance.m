//
//  Appearance.m
//  TowAlert
//
//  Created by Dalton on 3/4/16.
//  Copyright © 2016 Dalton. All rights reserved.
//

#import "Appearance.h"


@implementation Appearance

+ (void)initializeAppearanceDefaults {
    
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bluegray"]]];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    
    
    [[UILabel appearance] setTextColor:[UIColor colorWithRed:74/255.0 green:75/255.0 blue:76/255.0 alpha:1]];
    
    [[UINavigationBar appearance] setTranslucent:NO];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:122/255.0 green:197/255.0 blue:237/255.0 alpha:1],
                                                           NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"SystemFont" size: 34.0],
                                                           NSFontAttributeName,
                                                           nil]];
    
}

@end

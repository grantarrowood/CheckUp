//
//  ViewController.h
//  CheckUp
//
//  Created by Grant Arrowood on 1/15/17.
//  Copyright © 2017 Piglet Products. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <CoreData/CoreData.h>
#import <Accelerate/Accelerate.h>


@interface ViewController : UIViewController <CLLocationManagerDelegate> 

@property (nonatomic, strong) CLLocationManager *locationManager;
- (IBAction)stopAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@end


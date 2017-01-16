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
@import FirebaseDatabase;
@import FirebaseAuth;
@import Firebase;
@import FirebaseStorage;
#import <AVFoundation/AVFoundation.h>


@interface ViewController : UIViewController <CLLocationManagerDelegate> {
    int moments;
    NSString *parentId;
}
@property (nonatomic, strong) UIImagePickerController *poc;

@property (nonatomic, strong) CLLocationManager *locationManager;
- (IBAction)stopAction:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (strong, nonatomic) FIRDatabaseReference *ref;

@end


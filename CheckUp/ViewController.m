//
//  ViewController.m
//  CheckUp
//
//  Created by Grant Arrowood on 1/15/17.
//  Copyright © 2017 Piglet Products. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"
#import "Checker.h"

@interface ViewController ()

@end

@implementation ViewController

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDelegate:self];
    self.ref = [[FIRDatabase database] reference];
    //[[[_ref child:@"users"] child:[FIRAuth auth].currentUser.uid] setValue:@{@"accessType": @"Parent", @"subscriber": @"Yes", @"parentID": @"BJxCCMLhnzYPfi9BZrzm9RXCMxv1"}];
    NSString *userID = [FIRAuth auth].currentUser.uid;
    [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        parentId = snapshot.value[@"parentID"];
        [[[_ref child:@"settings"] child:snapshot.value[@"parentID"]] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            self.speedLabel.text = snapshot.value[@"speed"];
        } withCancelBlock:^(NSError * _Nonnull error) {
            NSLog(@"%@", error.localizedDescription);
        }];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startTracking:(id)sender {
    //self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    moments = 0;

}


-(void)sendData {
    if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus]==NotReachable)
    {
        //connection unavailable
        // USE CORE DATA
        NSLog(@"Using Core Data");
        NSManagedObjectContext *context = [self managedObjectContext];
        
        Checker  *check = [NSEntityDescription insertNewObjectForEntityForName:@"Checker" inManagedObjectContext:context];;
        [check setSpeed:self.locationManager.location.speed];
        [check setTimeofday:[NSDate date]];
        [check setCoordinatelat:self.locationManager.location.coordinate.latitude];
        [check setCoordinatelong:self.locationManager.location.coordinate.longitude];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        
    }
    else
    {
        //connection available
        // SEND TO SERVER
        NSLog(@"Sending To Server");
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Checker" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (result.count > 0) {
            for (Checker *object in result) {
                [[[[[_ref child:@"logs"] child:[FIRAuth auth].currentUser.uid] child:@"Drive 1"] child:[NSString stringWithFormat:@"Moment %i", moments]] setValue:@{@"speed": [NSString stringWithFormat:@"%f", [object speed]], @"timeOfDay": [NSString stringWithFormat:@"%@",[object timeofday]], @"coordinateLat": [NSString stringWithFormat:@"%f", [object coordinatelat]], @"coordinateLong": [NSString stringWithFormat:@"%f", [object coordinatelong]]}];
                moments++;
                if ([object speed] >= self.speedLabel.text.intValue) {
                    NSLog(@"EXCESSIVE SPEED = %f @ %f, %f", [object speed], [object coordinatelat], [object coordinatelong]);
                }
                NSLog(@"%f %f",[object speed], [object coordinatelong]);
            }
            for (int i = 0; i<result.count; i++) {
                NSManagedObject *object = (NSManagedObject *)[result objectAtIndex:i];
                
                [self.managedObjectContext deleteObject:object];
                
                NSError *deleteError = nil;
                
                if (![object.managedObjectContext save:&deleteError]) {
                    NSLog(@"Unable to save managed object context.");
                    NSLog(@"%@, %@", deleteError, deleteError.localizedDescription);
                }
            }
        }
        [[[[[_ref child:@"logs"] child:[FIRAuth auth].currentUser.uid] child:@"Drive 1"] child:[NSString stringWithFormat:@"Moment %i", moments]] setValue:@{@"speed": [NSString stringWithFormat:@"%f", self.locationManager.location.speed], @"timeOfDay": [NSString stringWithFormat:@"%@",[NSDate date]], @"coordinateLat": [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.latitude], @"coordinateLong": [NSString stringWithFormat:@"%f", self.locationManager.location.coordinate.longitude]}];
        moments++;
        if (self.locationManager.location.speed >= self.speedLabel.text.intValue) {
            NSLog(@"EXCESSIVE SPEED = %f @ %f, %f", self.locationManager.location.speed, self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
        }
    }
}




- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSLog(@"%@", [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude]);
        NSLog(@"%@", [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude]);
        NSLog(@"%@", [NSString stringWithFormat:@"%.8f", currentLocation.speed]);
        [self sendData];
        [self checkCamera];
    }
}

-(void)checkCamera {
    [[[_ref child:@"settings"] child:parentId] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        if ([snapshot.value[@"cameraActive"] isEqualToString:@"YES"]) {
            //CAMERA ACTIVATE
            self.poc = [[UIImagePickerController alloc] init];
            [self.poc setTitle:@"Take a photo."];
            [self.poc setDelegate:self];
            [self.poc setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self.poc setCameraDevice:UIImagePickerControllerCameraDeviceFront];
            self.poc.showsCameraControls = NO;
            [self.poc takePicture];
            [[[_ref child:@"settings"] child:parentId] setValue:@{@"cameraActive": @"NO"}];
            // Create a root reference
//            FIRStorage *storage = [FIRStorage storage];
//            
//            FIRStorageReference *storageRef = [storage reference];
//            
//            // Create a reference to "mountains.jpg"
//            FIRStorageReference *mountainsRef = [storageRef child:@"pic.jpg"];
//            
//            // Create a reference to 'images/mountains.jpg'
//            FIRStorageReference *mountainImagesRef = [storageRef child:@"images/pic.jpg"];
//            
//            // While the file names are the same, the references point to different files
//            [mountainsRef.name isEqualToString:mountainImagesRef.name];         // true
//            [mountainsRef.fullPath isEqualToString:mountainImagesRef.fullPath]; // false
        }
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (IBAction)stopAction:(id)sender {
    [self.locationManager stopUpdatingLocation];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Checker" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    NSError *error = nil;
//    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    for (Checker *object in result) {
//        NSLog(@"%f %f",[object speed], [object coordinatelong]);
//        
//    }
//    if (error) {
//        NSLog(@"Unable to execute fetch request.");
//        NSLog(@"%@, %@", error, error.localizedDescription);
//        
//    } else {
//        NSLog(@"%@", result);
//    }
//    for (int i = 0; i<result.count; i++) {
//        NSManagedObject *object = (NSManagedObject *)[result objectAtIndex:i];
//        
//        [self.managedObjectContext deleteObject:object];
//        
//        NSError *deleteError = nil;
//        
//        if (![object.managedObjectContext save:&deleteError]) {
//            NSLog(@"Unable to save managed object context.");
//            NSLog(@"%@, %@", deleteError, deleteError.localizedDescription);
//        }
//    }
    
}
@end

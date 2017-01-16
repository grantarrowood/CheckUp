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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startTracking:(id)sender {
    //self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
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
}

- (IBAction)stopAction:(id)sender {
    [self.locationManager stopUpdatingLocation];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Checker" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (Checker *object in result) {
        NSLog(@"%f %f",[object speed], [object coordinatelong]);
        
    }
    if (error) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        NSLog(@"%@", result);
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
@end

//
//  ParentViewController.h
//  CheckUp
//
//  Created by Grant Arrowood on 1/16/17.
//  Copyright © 2017 Piglet Products. All rights reserved.
//

#import <UIKit/UIKit.h>
@import FirebaseAuth;
@import FirebaseDatabase;
@import Firebase;

@interface ParentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *speedTextField;
- (IBAction)setAction:(id)sender;
@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

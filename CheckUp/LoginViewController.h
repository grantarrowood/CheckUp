//
//  LoginViewController.h
//  CheckUp
//
//  Created by Grant Arrowood on 1/16/17.
//  Copyright © 2017 Piglet Products. All rights reserved.
//

#import <UIKit/UIKit.h>
@import FirebaseDatabase;

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)loginButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
- (IBAction)registerButtonAction:(id)sender;
@property (strong, nonatomic) FIRDatabaseReference *ref;

@end

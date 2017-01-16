//
//  LoginViewController.m
//  CheckUp
//
//  Created by Grant Arrowood on 1/16/17.
//  Copyright © 2017 Piglet Products. All rights reserved.
//

#import "LoginViewController.h"
#import "ParentViewController.h"
#import "ViewController.h"
@import Firebase;
@import FirebaseAuth;

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.ref = [[FIRDatabase database] reference];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginButtonAction:(id)sender {
    
    [[FIRAuth auth] signInWithEmail:self.emailTextField.text
                           password:self.passwordTextField.text
                         completion:^(FIRUser *user, NSError *error) {
                             NSLog(@"Signed In");
                             [self getUserType:user];
                        }];
    
}
-(void)getUserType:(FIRUser *)user {
    NSString *userID = user.uid;
    [[[_ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Get user value
        if([snapshot.value[@"accessType"]  isEqual: @"Parent"]) {
            ParentViewController * viewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ParentViewController"];
            [self presentViewController:viewController animated:YES completion:nil];
        }
        if([snapshot.value[@"accessType"]  isEqual: @"Driver"]) {
            ViewController * viewController =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ViewController"];
            [self presentViewController:viewController animated:YES completion:nil];
        }
        // ...
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];

}
- (IBAction)registerButtonAction:(id)sender {
    
    [[FIRAuth auth]
     createUserWithEmail:self.emailTextField.text
     password:self.passwordTextField.text
     completion:^(FIRUser *_Nullable user,
                  NSError *_Nullable error) {
         NSLog(@"Logged In");
         [self getUserType:user];
     }];
    
    
}
@end

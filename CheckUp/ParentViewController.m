//
//  ParentViewController.m
//  CheckUp
//
//  Created by Grant Arrowood on 1/16/17.
//  Copyright © 2017 Piglet Products. All rights reserved.
//

#import "ParentViewController.h"

@interface ParentViewController ()

@end

@implementation ParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ref = [[FIRDatabase database] reference];

    NSString *userID = [FIRAuth auth].currentUser.uid;
    [[[_ref child:@"settings"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        self.speedTextField.text = snapshot.value[@"speed"];
    } withCancelBlock:^(NSError * _Nonnull error) {
        NSLog(@"%@", error.localizedDescription);
    }];
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

- (IBAction)setAction:(id)sender {
    
    [[[_ref child:@"settings"] child:[FIRAuth auth].currentUser.uid] setValue:@{@"speed": self.speedTextField.text}];
    
    
}
@end

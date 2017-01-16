//
//  Checker.h
//  CheckUp
//
//  Created by Grant Arrowood on 1/15/17.
//  Copyright © 2017 Piglet Products. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Checker : NSManagedObject

@property (nonatomic, retain) NSDate *timeofday;
@property (nonatomic) float coordinatelong;
@property (nonatomic) float coordinatelat;
@property (nonatomic) float acceleration;
@property (nonatomic) float distance;
@property (nonatomic) float speed;


@end

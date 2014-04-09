//
//  PushItem.m
//  Pushbullet
//
//  Created by Mohammad Abu-Garbeyyeh on 8/2/14.
//  Copyright (c) 2014 Mohammad Abu-Garbeyyeh. All rights reserved.
//

#import "PushItem.h"

@implementation PushItem

@synthesize firstValue = _firstValue;
@synthesize secondValue = _secondValue;
@synthesize arrayOfListItems = _arrayOfListItems;

- (void) setPushValues:(NSString *)firstValue second:(NSString *)secondValue
{
    self.firstValue = firstValue;
    self.secondValue = secondValue;
}

@end

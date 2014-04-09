//
//  PushItem.h
//  Pushbullet
//
//  Created by Mohammad Abu-Garbeyyeh on 8/2/14.
//  Copyright (c) 2014 Mohammad Abu-Garbeyyeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushBulletTarget.h"

typedef enum pushTypes
{
    PUSH_LINK = 0,
    PUSH_NOTE = 1,
    PUSH_FILE = 2,
    PUSH_LIST = 3,
    PUSH_ADDRESS = 4
} PushType;

@interface PushItem : NSObject {
    NSString *_firstValue;
    NSString *_secondValue;
    NSArray *_arrayOfListItems;
    PushType _type;
}

@property (nonatomic, retain) NSString *firstValue;
@property (nonatomic, retain) NSString *secondValue;
@property (nonatomic, retain) NSArray *arrayOfListItems;
@property (nonatomic) PushType type;

- (void) setPushValues:(NSString *)firstValue second:(NSString *)secondValue;

@end

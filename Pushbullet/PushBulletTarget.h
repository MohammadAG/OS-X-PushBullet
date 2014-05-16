//
//  PushBulletTarget.h
//  Pushbullet
//
//  Created by Mohammad Abu-Garbeyyeh on 8/2/14.
//  Copyright (c) 2014 Mohammad Abu-Garbeyyeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushItem.h"

typedef enum targetType
{
    TYPE_DEVICE = 0,
    TYPE_CONTACT = 1,
} TargetType;

@interface PushBulletTarget : NSObject {
    NSString *_iden;
    NSString *_email;
    NSString *_model;
    NSString *_manufacturer;
    NSString *_nickname;
    TargetType _type;
}

@property (nonatomic, retain) NSString *iden;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *model;
@property (nonatomic, retain) NSString *manufacturer;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic) TargetType type;

- (NSString *) getDisplayName;

@end

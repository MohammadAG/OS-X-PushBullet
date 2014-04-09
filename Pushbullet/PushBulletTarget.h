//
//  PushBulletTarget.h
//  Pushbullet
//
//  Created by Mohammad Abu-Garbeyyeh on 8/2/14.
//  Copyright (c) 2014 Mohammad Abu-Garbeyyeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushItem.h"

@interface PushBulletTarget : NSObject {
    NSString *_iden;
    NSString *_model;
    NSString *_manufacturer;
    NSString *_nickname;
    int type;
}

@property (nonatomic, retain) NSString *iden;
@property (nonatomic, retain) NSString *model;
@property (nonatomic, retain) NSString *manufacturer;
@property (nonatomic, retain) NSString *nickname;

- (NSString *) getDisplayName;

@end

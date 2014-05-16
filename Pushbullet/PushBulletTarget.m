//
//  PushBulletTarget.m
//  Pushbullet
//
//  Created by Mohammad Abu-Garbeyyeh on 8/2/14.
//  Copyright (c) 2014 Mohammad Abu-Garbeyyeh. All rights reserved.
//

#import "PushBulletTarget.h"

@implementation PushBulletTarget

@synthesize iden = _iden;
@synthesize email = _email;
@synthesize nickname = _nickname;
@synthesize manufacturer = _manufacturer;
@synthesize model = _model;

- (NSString *) getDisplayName
{
    if (_nickname != nil && _nickname.length > 0) {
        return _nickname;
    } else {
        return [NSString stringWithFormat:@"%@ %@", _manufacturer, _model];
    }
}

@end

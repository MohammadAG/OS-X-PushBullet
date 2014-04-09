//
//  BorderlessWindow.m
//  Pushbullet
//
//  Created by Mohammad Abu-Garbeyyeh on 10/2/14.
//  Copyright (c) 2014 Mohammad Abu-Garbeyyeh. All rights reserved.
//

#import "BorderlessWindow.h"

@implementation BorderlessWindow

- (void) setStyleMask:(NSUInteger)styleMask
{
    if (styleMask == NSBorderlessWindowMask) {
        [self setupWindowForEvents];
    }
    
    [super setStyleMask:styleMask];
}

- (BOOL) canBecomeKeyWindow
{
    return YES;
}

- (BOOL) canBecomeMainWindow
{
    return YES;
}

- (void)setupWindowForEvents{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignMainNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignKey:) name:NSWindowDidResignKeyNotification object:self];
}

-(void)windowDidResignKey:(NSNotification *)note {
    NSLog(@"Window lost focus in borderless mode, we have to quit");
    [self close];
}

@end

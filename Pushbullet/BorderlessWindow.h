//
//  BorderlessWindow.h
//  Pushbullet
//
//  Created by Mohammad Abu-Garbeyyeh on 10/2/14.
//  Copyright (c) 2014 Mohammad Abu-Garbeyyeh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BorderlessWindow : NSWindow

- (void)setStyleMask:(NSUInteger)styleMask;
- (BOOL)canBecomeKeyWindow;
- (BOOL)canBecomeMainWindow;

@end

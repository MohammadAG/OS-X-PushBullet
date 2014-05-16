//
//  AppDelegate.h
//  Pushbullet
//
//  Created by Mohammad Abu-Garbeyyeh on 7/2/14.
//  Copyright (c) 2014 Mohammad Abu-Garbeyyeh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PushBulletHandler.h"
#import "PushItem.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,PushBulletHandlerDelegate> {
    PushType _currentPushType;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *apiKeyTextField;
@property (weak) IBOutlet NSPopUpButton *devicesPopUpButton;
@property (weak) IBOutlet NSButton *linkButton;
@property (weak) IBOutlet NSButton *noteButton;
@property (weak) IBOutlet NSButton *addressButton;
@property (weak) IBOutlet NSButton *listButton;
@property (weak) IBOutlet NSButton *fileButton;
@property (weak) IBOutlet NSTextField *firstTextField;
@property (weak) IBOutlet NSTextField *secondTextField;
@property (weak) IBOutlet NSButton *clearButton;
@property (weak) IBOutlet NSButton *pushItButton;
@property (weak) IBOutlet NSButton *browseButton;

@property (nonatomic,strong) PushBulletHandler *pushBulletHandler;
@property (nonatomic,strong) NSMutableArray *pushTypeButtons;
@property (nonatomic,strong) NSArray *pushTargets;
@property (nonatomic,strong) NSArray *contactTargets;

@property (nonatomic) NSInteger lastIndexSelected;
@property (nonatomic) PushType currentPushType;
@property (nonatomic) BOOL shouldCloseOnPush;

- (IBAction)pushItButtonClicked:(NSButton *)sender;
- (IBAction)clearButtonClicked:(NSButton *)sender;
- (IBAction)refreshButtonClciked:(NSButton *)sender;
- (IBAction)pushTypeButtonClicked:(NSButton *)sender;
- (IBAction)browseButtonClicked:(NSButton *)sender;

- (void)targetsRefreshed:(PushBulletHandler *)pushBulletHandler targetsDidFinishLoading:(NSArray *)targets;
- (void)pushSucceeded:(BOOL) success error:(NSString *)error;

- (void)updateUiForType:(PushType) type;
- (void)setFieldPlaceholderText:(NSString *)firstText secondText:(NSString *)secondText;

- (PushBulletTarget *)getTargetWithIden:(NSString *) iden;
- (PushType)getPushTypeFromInt:(NSNumber *) integer;

@end

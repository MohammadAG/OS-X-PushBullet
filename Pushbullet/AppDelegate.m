//
//  AppDelegate.m
//  Pushbullet
//
//  Created by Mohammad Abu-Garbeyyeh on 7/2/14.
//  Copyright (c) 2014 Mohammad Abu-Garbeyyeh. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize currentPushType = _currentPushType;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _pushBulletHandler = [[PushBulletHandler alloc] init];
    [_pushBulletHandler setDelegate:self];
    _pushTypeButtons = [[NSMutableArray alloc] init];
    [_pushTypeButtons addObject:self.linkButton];
    [_pushTypeButtons addObject:self.noteButton];
    [_pushTypeButtons addObject:self.addressButton];
    [_pushTypeButtons addObject:self.listButton];
    [_pushTypeButtons addObject:self.fileButton];
    
    [_secondTextField setTarget:self];
    [_secondTextField setAction:@selector(returnClicked:)];
    
    [_firstTextField setTarget:self];
    [_firstTextField setAction:@selector(returnClicked:)];
    
    _currentPushType = PUSH_LINK;
    [self updateUiForType:_currentPushType selectButton:NO];
    
    [self loadSettings];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (_shouldCloseOnPush) {
        [self.window makeKeyAndOrderFront:self.window];
    }
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    NSLog(@"Saving settings");
    [self saveSettings];
}

- (void) loadSettings
{
    NSLog(@"Loading settings");
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *api_key = [prefs stringForKey:@"api_key"];
    if (api_key != nil) {
        [self.apiKeyTextField setStringValue:api_key];
        [self.pushBulletHandler setApiKey:api_key];
        [self.pushBulletHandler refreshListOfDevices];
        
        [self.firstTextField becomeFirstResponder];
    }
    
    NSInteger currentTypeInteger = [prefs integerForKey:@"last_push_type"];
    NSNumber *number = [NSNumber numberWithInteger:currentTypeInteger];
    
    _currentPushType = [self getPushTypeFromInt:number];
    
    [self updateUiForType:_currentPushType selectButton:YES];
    
    _lastIndexSelected = [prefs integerForKey:@"last_selected_device_index"];
}

- (void) saveSettings
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[self.pushBulletHandler apiKey] forKey:@"api_key"];
    [prefs setObject:@(_currentPushType) forKey:@"last_push_type"];
    [prefs setObject:@([_devicesPopUpButton indexOfSelectedItem]) forKey:@"last_selected_device_index"];
    [prefs synchronize];
}


- (IBAction)clearButtonClicked:(NSButton *)sender
{
    [_firstTextField setStringValue:@""];
    [_secondTextField setStringValue:@""];
    
    [_firstTextField becomeFirstResponder];
}

- (IBAction)refreshButtonClciked:(NSButton *)sender
{
    NSLog(@"Refresh button clicked");
    
    if ([_apiKeyTextField stringValue].length <= 0) {
        NSLog(@"API Key is empty");
        return;
    }
    
    if (_pushBulletHandler != nil) {
        [_pushBulletHandler setApiKey:[_apiKeyTextField stringValue]];
        [_pushBulletHandler refreshListOfDevices];
    }
    
    [self saveSettings];
}

- (IBAction)browseButtonClicked:(NSButton *)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            NSError *err = nil;
            NSFileHandle *handle = [NSFileHandle fileHandleForReadingFromURL:url error:&err];
            if (err) {
                [_secondTextField setStringValue:@"Error occured opening file"];
                return;
            }
            
            unsigned long filesize = [handle seekToEndOfFile];
            if (filesize >= 26214400) {
                NSLog(@"File too big");
                NSAlert *alert = [[NSAlert alloc] init];
                [alert addButtonWithTitle:@"Okay"];
                [alert setMessageText:@"File too big"];
                [alert setInformativeText:@"Pushbullet has a 25MB file size limit"];
                [alert setAlertStyle:NSCriticalAlertStyle];
                [alert beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
                return;
            }
            [_secondTextField setStringValue:[url absoluteString]];
        }
    }
}

- (void) setMostUiElementsEnabled:(BOOL)enabled
{
    [_pushItButton setEnabled:enabled];
    [_clearButton setEnabled:enabled];
    [_firstTextField setEnabled:enabled];
    [_secondTextField setEnabled:enabled];
    [_apiKeyTextField setEnabled:enabled];
    [_devicesPopUpButton setEnabled:enabled];
    for (NSButton *button in _pushTypeButtons) {
        [button setEnabled:enabled];
    }
}

- (IBAction) pushItButtonClicked:(NSButton *)sender
{
    if (_currentPushType == PUSH_FILE) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Okay"];
        [alert setMessageText:@"Not yet implemented"];
        [alert setInformativeText:@"Sorry, file uploads haven't been implemented yet, please use pushbullet.com till it's done."];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert beginSheetModalForWindow:[self window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
        return;
    }
    
    [self setMostUiElementsEnabled:NO];
    NSMenuItem *item = [self.devicesPopUpButton itemAtIndex:[self.devicesPopUpButton indexOfSelectedItem]];
    
    NSString *iden = [item keyEquivalent];
    
    PushBulletTarget *target = [self getTargetWithIden:iden];
    
    NSString *firstText = [_firstTextField stringValue];
    NSString *secondText = [_secondTextField stringValue];
    
    PushItem *pushItem = [[PushItem alloc] init];
    [pushItem setPushValues:firstText second:secondText];
    pushItem.type = _currentPushType;
    
    [_pushBulletHandler pushToDevice:target item:pushItem];
}

- (PushBulletTarget *) getTargetWithIden:(NSString *) iden
{
    for (PushBulletTarget *target in _pushTargets) {
        if ([target.iden isEqualToString:iden]) {
            return target;
        }
    }
    
    return nil;
}

- (void) targetsRefreshed:(PushBulletHandler *)pushBulletHandler targetsDidFinishLoading:(NSArray *)targets
{
    _pushTargets = targets;
    NSMenu *menu = [[NSMenu alloc] init];
    for (PushBulletTarget *target in targets) {
        NSMenuItem *mi = [[NSMenuItem alloc]
                          initWithTitle:[target getDisplayName]
                          action:Nil
                          keyEquivalent:target.iden];
        
        [menu addItem:mi];
    }
    [self.devicesPopUpButton setMenu:menu];
    
    if (self.lastIndexSelected != -1) {
        if ([[menu itemArray] count] >= self.lastIndexSelected) {
            [self.devicesPopUpButton selectItemAtIndex:self.lastIndexSelected];
        }
    }
}

- (void) pushSucceeded:(BOOL) success error:(NSString *)error
{
    [self setMostUiElementsEnabled:YES];
    if (_shouldCloseOnPush) {
        [self.window close];
    }
}

- (IBAction) pushTypeButtonClicked:(NSButton *)sender
{
    for (NSButton *button in _pushTypeButtons) {
        if (button != sender) {
            [button setState:NSOffState];
        }
    }
    
    BOOL isOneButtonPressed = false;
    for (NSButton *button in _pushTypeButtons) {
        if ([button state] == NSOnState) {
            isOneButtonPressed = true;
        }
    }
    
    if (!isOneButtonPressed) {
        [sender setState:NSOnState];
    }
    
    if (sender == _linkButton) {
        _currentPushType = PUSH_LINK;
    } else if (sender == _noteButton) {
        _currentPushType = PUSH_NOTE;
    } else if (sender == _addressButton) {
        _currentPushType = PUSH_ADDRESS;
    } else if (sender == _listButton) {
        _currentPushType = PUSH_LIST;
    } else if (sender == _fileButton) {
        _currentPushType = PUSH_FILE;
    }
    
    [self updateUiForType:_currentPushType];
}

- (void) setPushType:(PushType) type
{
    _currentPushType = type;
}

- (PushType) getPushTypeFromInt:(NSNumber *) integer
{
    PushType type = [integer intValue];
    return type;
}

- (void) updateUiForType:(PushType)type selectButton:(BOOL)selectButton
{
    NSButton *buttonToChange = nil;
    switch (type) {
        case PUSH_NOTE:
            [self setFieldPlaceholderText:@"Title" secondText:@"Message"];
            if (selectButton) { buttonToChange = _noteButton; }
            break;
        case PUSH_LIST:
            [self setFieldPlaceholderText:@"List title" secondText:@"Item 1|||Item 2|||Item 3 (Items separated by \"|||\")"];
            if (selectButton) { buttonToChange = _listButton; }
            break;
        case PUSH_ADDRESS:
            [self setFieldPlaceholderText:@"Address" secondText:@"Street address, place or name of location"];
            if (selectButton) { buttonToChange = _addressButton; }
            break;
        case PUSH_FILE:
            [self setFieldPlaceholderText:@"Sending file..." secondText:@"Select a file or type in a path"];
            if (selectButton) { buttonToChange = _fileButton; }
            break;
        case PUSH_LINK:
            [self setFieldPlaceholderText:@"Link title" secondText:@"http://www.example.com"];
            if (selectButton) { buttonToChange = _linkButton; }
            break;
    }
    
    if (type == PUSH_FILE) {
        [_firstTextField setEnabled:NO];
        [_browseButton setHidden:NO];
    } else {
        [_firstTextField setEnabled:YES];
        [_firstTextField becomeFirstResponder];
        [_browseButton setHidden:YES];
    }
    
    if (selectButton) {
        for (NSButton *button in _pushTypeButtons) {
            [button setState:NSOffState];
        }
        
        [buttonToChange setState:NSOnState];
    }
}

- (void) updateUiForType:(PushType)type
{
    [self updateUiForType:type selectButton:NO];
}

- (void) setFieldPlaceholderText:(NSString *)firstText secondText:(NSString *)secondText
{
    [[self.firstTextField cell] setPlaceholderString:firstText];
    [[self.secondTextField cell] setPlaceholderString:secondText];
}

- (void) returnClicked:(id)sender
{
    if (sender == _firstTextField) {
        if ([_secondTextField stringValue].length > 0) {
            [self pushItButtonClicked:_pushItButton];
        } else {
            [_secondTextField becomeFirstResponder];
        }
    } else if (sender == _secondTextField) {
        [self pushItButtonClicked:_pushItButton];
    }
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    // Register ourselves as a URL handler for this URL
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
                                                       andSelector:@selector(getUrl:withReplyEvent:)
                                                     forEventClass:kInternetEventClass
                                                        andEventID:kAEGetURL];
}

- (void)getUrl:(NSAppleEventDescriptor *)event
withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSPoint mouseLoc = [NSEvent mouseLocation];
    [self.window setFrameTopLeftPoint:mouseLoc];
    [self.window setStyleMask:NSBorderlessWindowMask];
    
    [self.window makeKeyAndOrderFront:self.window];
    
    _shouldCloseOnPush = YES;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *urlStr = [[event paramDescriptorForKeyword:keyDirectObject]
                        stringValue];
    NSLog(@"Received URL %@", urlStr);
    
    urlStr = [urlStr substringFromIndex:13];
    NSString *stuffToPush;
    if ([urlStr hasPrefix:@"note/"]) {
        [prefs setObject:@(PUSH_NOTE) forKey:@"last_push_type"];
        stuffToPush = [urlStr substringFromIndex:5];
    } else if ([urlStr hasPrefix:@"url/"]) {
        [prefs setObject:@(PUSH_LINK) forKey:@"last_push_type"];
        stuffToPush = [urlStr substringFromIndex:4];
    }
    [prefs synchronize];
    
    [_secondTextField setStringValue:stuffToPush];
}

@end

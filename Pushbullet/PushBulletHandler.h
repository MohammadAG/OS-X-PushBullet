//
//  PushBulletHandler.h
//  Pushbullet
//
//  Created by Mohammad Abu-Garbeyyeh on 8/2/14.
//  Copyright (c) 2014 Mohammad Abu-Garbeyyeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PushBulletTarget.h"

@interface PushBulletHandler : NSObject {
    
    NSString *_apiKey;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSString *apiKey;

@property (strong) NSMutableData *refreshReceivedData;
@property (strong) NSURLConnection *refreshDevicesConnection;

@property (strong) NSMutableData *pushReceivedData;
@property (strong) NSURLConnection *pushConnection;

@property (strong) NSMutableData *contactsReceivedData;
@property (strong) NSURLConnection *contactsRefreshConnection;

- (NSString *) encodeString:(NSString *) string;

- (void) pushToDevice:(PushBulletTarget *) target item:(PushItem *)item;
- (void) refreshConnectionFinished;
- (void) pushConnectionFinished;
- (void) setApiKey:(NSString *) apiKey;
- (void) refreshListOfDevices;

@end

@protocol PushBulletHandlerDelegate <NSObject>
- (void)targetsRefreshed:(PushBulletHandler *)pushBulletHandler targetsDidFinishLoading:(NSArray *)targets;
- (void)contactsRefreshed:(PushBulletHandler *)pushBulletHandler contactsDidFinishLoading:(NSArray *)contacts;
- (void) pushSucceeded:(BOOL)success error:(NSString *)error;
@end

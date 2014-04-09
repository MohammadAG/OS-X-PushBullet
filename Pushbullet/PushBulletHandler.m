//
//  PushBulletHandler.m
//  Pushbullet
//
//  Created by Mohammad Abu-Garbeyyeh on 8/2/14.
//  Copyright (c) 2014 Mohammad Abu-Garbeyyeh. All rights reserved.
//

#import "PushBulletHandler.h"


@implementation PushBulletHandler

@synthesize apiKey = _apiKey;

static char *alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString *)encodeString:(NSString *)data
{
    const char *input = [data cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned long inputLength = [data length];
    unsigned long modulo = inputLength % 3;
    unsigned long outputLength = (inputLength / 3) * 4 + (modulo ? 4 : 0);
    unsigned long j = 0;
    
    // Do not forget about trailing zero
    unsigned char *output = malloc(outputLength + 1);
    output[outputLength] = 0;
    
    // Here are no checks inside the loop, so it works much faster than other implementations
    for (unsigned long i = 0; i < inputLength; i += 3) {
        output[j++] = alphabet[ (input[i] & 0xFC) >> 2 ];
        output[j++] = alphabet[ ((input[i] & 0x03) << 4) | ((input[i + 1] & 0xF0) >> 4) ];
        output[j++] = alphabet[ ((input[i + 1] & 0x0F)) << 2 | ((input[i + 2] & 0xC0) >> 6) ];
        output[j++] = alphabet[ (input[i + 2] & 0x3F) ];
    }
    // Padding in the end of encoded string directly depends of modulo
    if (modulo > 0) {
        output[outputLength - 1] = '=';
        if (modulo == 1)
            output[outputLength - 2] = '=';
    }
    NSString *s = [NSString stringWithUTF8String:(const char *)output];
    free(output);
    return s;
}

- (void) refreshListOfDevices
{
    NSLog(@"Refresing list of devices from push bullet %@", [self apiKey]);
    
    // Create the request.
    NSMutableURLRequest *theRequest =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.pushbullet.com/api/devices"]
                            cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSString *loginString = [NSString stringWithFormat:@"%@:", [self apiKey]];
    NSString *authString = [@"Basic " stringByAppendingFormat:@"%@", [self encodeString:loginString]];
    [theRequest setValue:authString forHTTPHeaderField:@"Authorization"];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    self.refreshReceivedData = [NSMutableData dataWithCapacity: 0];
    
    self.refreshDevicesConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (!self.refreshDevicesConnection) {
        self.refreshReceivedData = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == self.refreshDevicesConnection)
        [self.refreshReceivedData setLength:0];
    else if (connection == self.pushConnection)
        [self.pushReceivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == self.refreshDevicesConnection)
        [self.refreshReceivedData appendData:data];
    else if (connection == self.pushConnection)
        [self.pushReceivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    connection = nil;
    if (connection == self.refreshDevicesConnection)
        self.refreshReceivedData = nil;
    else if (connection == self.pushConnection)
        self.pushReceivedData = nil;
    
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (connection == self.refreshDevicesConnection)
        [self refreshConnectionFinished];
    else if (connection == self.pushConnection)
        [self pushConnectionFinished];
}

- (void) refreshConnectionFinished
{
    NSLog(@"Succeeded! Received %lu bytes of data", (unsigned long)[self.refreshReceivedData length]);
    
    NSError *error = nil;
    id object = [NSJSONSerialization
                 JSONObjectWithData:_refreshReceivedData
                 options:0
                 error:&error];
    
    if(error) {
        NSLog(@"Error parsing JSON");
        return;
    }
    
    NSMutableArray *targets = [[NSMutableArray alloc] init];
    
    NSLog(@"Trying to print device names");
    if ([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *results = object;
        NSArray *devices = [results objectForKey:@"devices"];
        NSLog(@"Got devices dictionary of type %@", [devices className]);
        
        for (NSDictionary *device in devices) {
            NSDictionary *extras = [device valueForKey:@"extras"];
            
            NSString *nickname = [extras objectForKey:@"nickname"];
            NSString *manufacturer = [extras objectForKey:@"manufacturer"];
            NSString *model = [extras objectForKey:@"model"];
            NSString *androidVersion = [extras objectForKey:@"android_version"];
            NSString *iden = [device valueForKey:@"iden"];
            NSString *deviceType = @"device";
            NSString *androidVersionString = [NSString stringWithFormat:@" running Android version %@ ", androidVersion];
            if ([[NSNull null] isEqualTo:androidVersion]) {
                deviceType = @"browser";
                androidVersionString = @" ";
            }
            
            PushBulletTarget *target = [[PushBulletTarget alloc] init];
            [target setNickname:nickname];
            [target setManufacturer:manufacturer];
            [target setIden:iden];
            [target setModel:model];
            
            [targets addObject:target];
        }
    } else {
        NSLog(@"Error parsing JSON, invalid response");
        return;
    }
    
    self.refreshDevicesConnection = nil;
    self.refreshReceivedData = nil;
    
    if (_delegate && [_delegate respondsToSelector:@selector(targetsRefreshed:targetsDidFinishLoading:)]) {
    	NSLog(@"Delivering results to UI!");
    	[_delegate targetsRefreshed:self targetsDidFinishLoading:targets];
    } else {
    	NSLog(@"Delegate not set, refresh finished though");
    }
}

- (void) pushConnectionFinished
{
    if (_delegate && [_delegate respondsToSelector:@selector(pushSucceeded:error:)]) {
    	NSLog(@"Push successful, notifying UI");
    	[_delegate pushSucceeded:YES error:nil];
    } else {
    	NSLog(@"Delegate not set, push succeeded though");
    }
}

-(NSURLRequest *)postRequestWithURL: (NSString *)url

                               data: (NSData *)data
                           fileName: (NSString*)fileName
{
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];
    [urlRequest setURL:[NSURL URLWithString:url]];
    //[urlRequest setURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    
    NSString *myboundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",myboundary];
    [urlRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    
    //[urlRequest addValue: [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry] forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postData = [NSMutableData data]; //[NSMutableData dataWithCapacity:[data length] + 512];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", myboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", fileName]dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[NSData dataWithData:data]];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", myboundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [urlRequest setHTTPBody:postData];
    return urlRequest;
}

- (void) pushToDevice:(PushBulletTarget *)target item:(PushItem *)item
{
    NSString *firstDataTitle;
    NSString *secondDataTitle;
    NSString *type;
    
    switch (item.type) {
        case PUSH_NOTE:
            firstDataTitle = @"title";
            secondDataTitle = @"body";
            type = @"note";
            break;
        case PUSH_LINK:
            firstDataTitle = @"title";
            secondDataTitle = @"url";
            type = @"link";
            break;
        case PUSH_ADDRESS:
            firstDataTitle = @"name";
            secondDataTitle = @"address";
            type = @"address";
            break;
        case PUSH_LIST:
            firstDataTitle = @"title";
            secondDataTitle = @"items";
            type = @"list";
            break;
        case PUSH_FILE:
            firstDataTitle = secondDataTitle = @"";
            type = @"file";
            return;
    }
    
    NSLog(@"Pushing to device %@ with iden %@", [target getDisplayName], target.iden);
    NSLog(@"Pushing data with title: %@ and body %@", [item firstValue], [item secondValue]);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.pushbullet.com/api/pushes"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *loginString = [NSString stringWithFormat:@"%@:", [self apiKey]];
    NSString *authString = [@"Basic " stringByAppendingFormat:@"%@", [self encodeString:loginString]];
    [request setValue:authString forHTTPHeaderField:@"Authorization"];
    
    NSMutableDictionary *pushDictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
    [pushDictionary setObject:type forKey:@"type"];
    [pushDictionary setObject:item.firstValue forKey:firstDataTitle];
    if (item.type == PUSH_LIST) {
        NSArray *array = [item.secondValue componentsSeparatedByString:@"|||"];
        [pushDictionary setObject:array forKey:@"items"];
    } else {
        [pushDictionary setObject:item.secondValue forKey:secondDataTitle];
    }
    [pushDictionary setObject:target.iden forKey:@"device_iden"];
    
    NSData *pushData = [NSJSONSerialization dataWithJSONObject:pushDictionary options:0 error:NULL];
    [request setHTTPBody:pushData];
    
    self.pushConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!self.pushConnection) {
        self.pushReceivedData = nil;
        NSLog(@"Error doing request");
    }
}

@end

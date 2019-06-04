//
//  JFJSAPILocation.m
//  JFJSKit
//
//  Created by jumpingfrog0 on 2019/06/04.
//
//  Copyright (c) 2019 Donghong Huang <jumpingfrog0@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "JFJSAPILocation.h"
#import <CoreLocation/CoreLocation.h>

@interface JFJSAPILocation ()<CLLocationManagerDelegate>

@property (nonatomic, assign, getter=isLocating) BOOL locating;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, copy) JFJSAPICompletionBlock completion;

@end

@implementation JFJSAPILocation

+ (NSString *)command
{
    return @"get_location";
}

- (void)runOnCompletion:(JFJSAPICompletionBlock)completion
{
    self.completion = completion;

    __weak JFJSAPILocation *weakSelf = self;
    [self checkLocationServicePermission:^(BOOL valid) {
        if (valid) {
            if (!weakSelf.isLocating) {
                weakSelf.locating = YES;
                [weakSelf.locationManager startUpdatingLocation];
            }
        }
    }];
}

#pragma mark-- location
- (void)locateSuccess:(CLLocation *)location
{
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[location.timestamp timeIntervalSinceNow];
    if (locationAge > 30.0) return;

    // test that the horizontal accuracy does not indicate an invalid measurement
    if (location.horizontalAccuracy < 0) {
        return;
    }

    NSDictionary *result = @{
        @"longitude": @(location.coordinate.longitude),
        @"latitude": @(location.coordinate.latitude),
    };

    self.locating = NO;
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager          = nil;

    [self.request onSuccess:result];

    if (self.completion) {
        self.completion();
    }
}

- (void)locateFailed
{
    NSString *errorDescription = @"获取定位失败";
    NSDictionary *result       = @{
        @"code": @(0),
        @"msg": errorDescription,
    };

    self.locating = NO;
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager          = nil;

    [self.request onFailure:result];

    if (self.completion) {
        self.completion();
    }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self locateSuccess:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self locateSuccess:locations.lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self locateFailed];
}

#pragma mark--
- (void)checkLocationServicePermission:(void (^)(BOOL))block
{
    __weak JFJSAPILocation *weakSelf = self;
    void (^alert)()                   = ^{
        NSString *title              = @"";
        NSString *message            = @"";
        UIAlertControllerStyle style = UIAlertControllerStyleAlert;
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:style];

        UIAlertActionStyle cancelStyle = UIAlertActionStyleCancel;
        UIAlertAction *cancel          = [UIAlertAction actionWithTitle:@"取消" style:cancelStyle handler:nil];

        UIAlertActionStyle defaultStyle = UIAlertActionStyleDefault;
        UIAlertAction *confirm          = [UIAlertAction actionWithTitle:@"确认删除"
                                                          style:defaultStyle
                                                        handler:^(UIAlertAction *_Nonnull action){
                                                        }];
        [ac addAction:cancel];
        [ac addAction:confirm];
        [weakSelf.request.viewController presentViewController:ac animated:YES completion:nil];
    };

    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
        if (kCLAuthorizationStatusNotDetermined == status) {
            if (block) {
                block(NO);
            }
        } else if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
            if (block) {
                block(NO);
            }
        } else {
            if (block) {
                block(YES);
            }
        }
    } else {
        alert();
    }
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    return _locationManager;
}

@end

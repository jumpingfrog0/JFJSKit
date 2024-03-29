//
//  JFJSKitPlugin.m
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


#import "JFJSKitPlugin.h"

@implementation JFJSKitPlugin

- (BOOL)_allowScheme:(NSString *)scheme {
    return [scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]
            || [self.config.allowSchemes containsObject:scheme];
}

- (BOOL)handleRequest:(id<JFJSAPIRequestProtocol>)request {
    NSString *scheme = request.url.scheme ?: @"";

    if ([self _allowScheme:scheme]) {
        return [self.apiService sendRequest:request];
    }

    BOOL allowScheme = [self.config.openURLSchemes[scheme] boolValue];
    if (allowScheme) {
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:request.url]) {
            if (@available(iOS 10, *)) {
                [app openURL:request.url options:@{} completionHandler:nil];
            } else {
                [app openURL:request.url];
            }
        }
    }

    return NO;
}

@end

//
//  JFJSKitRCTPlugin.m
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

#import "JFJSKitRCTPlugin.h"
#import "JFJSAPIRCTRequest.h"
#import "RCTBridge+JFJSKitPlugin.h"
#import "JFJSKitPlugin.h"
#import <React/RCTBridge+Private.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTRootView.h>
#import "JFJSKit.h"
#import <React/RCTAssert.h>

@interface JFJSKitRCTPlugin ()<RCTBridgeModule>

@end

@implementation JFJSKitRCTPlugin
@synthesize bridge = _bridge;

RCT_EXTERN void RCTRegisterModule(Class);

+ (NSString *)moduleName {
    NSString *name = JSKitGetRCTModule();
    RCTAssert(name.length <= 0, @"You must register a react-native module at first.");
    return name;
}

+ (void)load {
    RCTRegisterModule(self);
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(sendPromiseProtocol: (NSString *)protocolUrl
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)rejecte) {
    RCTBridge *rootViewBridge = [self.bridge parentBridge];

    JFJSAPIRCTRequest *rctRequest = [[JFJSAPIRCTRequest alloc] init];
    rctRequest.url                 = [NSURL URLWithString:protocolUrl];
    rctRequest.resolver            = resolve;
    rctRequest.view                = rootViewBridge.jf_jskit_rctRootView;
    rctRequest.viewController      = rootViewBridge.jf_jskit_rctRootView.reactViewController;

    [rootViewBridge.jf_jskit_plugin handleRequest:rctRequest];
}

@end

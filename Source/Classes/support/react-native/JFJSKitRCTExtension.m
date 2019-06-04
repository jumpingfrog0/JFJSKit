//
//  JFJSKitRCTExtension.m
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

#import "JFJSKitRCTExtension.h"
#import "JFJSAPIRCTRequest.h"
#import "RCTBridge+JFJSKitExtension.h"
#import "JFJSKitExtension.h"
#import <React/RCTBridge+Private.h>
#import <React/RCTRootView.h>

@interface JFJSKitRCTExtension ()<RCTBridgeModule>

@end

@implementation JFJSKitRCTExtension
@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(JudaoJsBridge);

RCT_EXPORT_METHOD(sendPromiseProtocol
                  : (NSString *)protocolUrl resolver
                  : (RCTPromiseResolveBlock)resolve rejecter
                  : (RCTPromiseRejectBlock)reject) {
    RCTBridge *rootViewBridge = [self.bridge parentBridge];

    JFJSAPIRCTRequest *rctRequest = [[JFJSAPIRCTRequest alloc] init];
    rctRequest.url                 = [NSURL URLWithString:protocolUrl];
    rctRequest.resolver            = resolve;
    rctRequest.view                = rootViewBridge.mzd_jskit_rctRootView;
    rctRequest.viewController      = rootViewBridge.mzd_jskit_rctRootView.reactViewController;

    [rootViewBridge.mzd_jskit_extension handleRequest:rctRequest];
}

@end

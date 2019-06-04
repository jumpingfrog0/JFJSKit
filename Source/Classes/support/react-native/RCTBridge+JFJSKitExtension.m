//
//  RCTBridge+JFJSKitExtension.m
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

#import <React/RCTBridge.h>
#import <objc/runtime.h>
#import "RCTBridge+JFJSKitExtension.h"
#import "JFJSKitExtension.h"

static char kJFRCTBridgeProperty_jskit_extension;
static char kJFRCTBridgeProperty_jskit_rctRootView;
static char kJFRCTBridgeProperty_jskit_rctRootViewStack;

@implementation RCTBridge (JFJSKitExtension)

- (JFJSKitExtension *)mzd_jskit_extension {
    return objc_getAssociatedObject(self, &kJFRCTBridgeProperty_jskit_extension);
}

- (void)setMzd_jskit_extension:(JFJSKitExtension *)extension {
    if (self.mzd_jskit_extension != extension) {
        objc_setAssociatedObject(
            self, &kJFRCTBridgeProperty_jskit_extension, extension, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (RCTRootView *)mzd_jskit_rctRootView {
    return objc_getAssociatedObject(self, &kJFRCTBridgeProperty_jskit_rctRootView);
}

- (void)setMzd_jskit_rctRootView:(RCTRootView *)rootView {
    if (self.mzd_jskit_rctRootView != rootView) {
        objc_setAssociatedObject(
            self, &kJFRCTBridgeProperty_jskit_rctRootView, rootView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (rootView != self.mzd_jskit_rctRootViewStack.lastObject) {
            NSMutableArray *stack = [self.mzd_jskit_rctRootViewStack mutableCopy];
            [stack addObject:rootView];
            [self setMzd_jskit_rctRootViewStack:stack];
        }
    }
}

- (NSArray<__kindof RCTRootView *> *)mzd_jskit_rctRootViewStack {
    return objc_getAssociatedObject(self, &kJFRCTBridgeProperty_jskit_rctRootViewStack);
}

- (void)setMzd_jskit_rctRootViewStack:(NSArray<__kindof RCTRootView *> *)stack {
    if (self.mzd_jskit_rctRootViewStack != stack) {
        objc_setAssociatedObject(self, &kJFRCTBridgeProperty_jskit_rctRootViewStack, stack, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [self setMzd_jskit_rctRootView:stack.lastObject];
    }
}

@end

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

- (JFJSKitExtension *)jf_jskit_extension {
    return objc_getAssociatedObject(self, &kJFRCTBridgeProperty_jskit_extension);
}

- (void)setJf_jskit_extension:(JFJSKitExtension *)extension {
    if (self.jf_jskit_extension != extension) {
        objc_setAssociatedObject(
            self, &kJFRCTBridgeProperty_jskit_extension, extension, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (RCTRootView *)jf_jskit_rctRootView {
    return objc_getAssociatedObject(self, &kJFRCTBridgeProperty_jskit_rctRootView);
}

- (void)setJf_jskit_rctRootView:(RCTRootView *)rootView {
    if (self.jf_jskit_rctRootView != rootView) {
        objc_setAssociatedObject(
            self, &kJFRCTBridgeProperty_jskit_rctRootView, rootView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (rootView != self.jf_jskit_rctRootViewStack.lastObject) {
            NSMutableArray *stack = [self.jf_jskit_rctRootViewStack mutableCopy];
            [stack addObject:rootView];
            [self setJf_jskit_rctRootViewStack:stack];
        }
    }
}

- (NSArray<__kindof RCTRootView *> *)jf_jskit_rctRootViewStack {
    return objc_getAssociatedObject(self, &kJFRCTBridgeProperty_jskit_rctRootViewStack);
}

- (void)setJf_jskit_rctRootViewStack:(NSArray<__kindof RCTRootView *> *)stack {
    if (self.jf_jskit_rctRootViewStack != stack) {
        objc_setAssociatedObject(self, &kJFRCTBridgeProperty_jskit_rctRootViewStack, stack, OBJC_ASSOCIATION_COPY_NONATOMIC);
        [self setJf_jskit_rctRootView:stack.lastObject];
    }
}

@end

//
//  WKWebView+JFJSKitExtension_jsInject.m
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

#import "JFJSKitDefines.h"
#import "NSObject+JFJSKitAdditions.h"
#import "WKWebView+JFJSKitExtension.h"
#import "WKWebView+JFJSKitExtension_jsInject.h"
#import <objc/runtime.h>

static char kJFWKWebViewProperty_jskit_extension_jsInject_jsURL;
static char kJFWKWebViewProperty_jskit_extension_jsInject_jsURLBlock;

@implementation WKWebView (JFJSKitExtension_jsInject)

+ (void)load {
    [self mzd_jskit_extension_jsInject_hookNavigationDelegate];
}

#pragma mark-- HookNaivationDelegate
+ (void)mzd_jskit_extension_jsInject_hookNavigationDelegate {
    SEL originalSelector = @selector(setNavigationDelegate:);
    SEL swizzledSelector = @selector(mzd_jskit_extension_jsInject_setNavigationDelegate:);

    [self mzd_jskit_changeSelector:originalSelector withSelector:swizzledSelector];
}

- (void)mzd_jskit_extension_jsInject_setNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    Class aClass = [delegate class];

    SEL originalSelector = @selector(webView:didFinishNavigation:);
    SEL defaultSelector  = @selector(mzd_jskit_extension_jsInject_default_webView:didFinishNavigation:);
    SEL swizzledSelector = @selector(mzd_jskit_extension_jsInject_webView:didFinishNavigation:);
    [self mzd_jskit_hookSelector:originalSelector
        withDefaultImplementSelector:defaultSelector
                    swizzledSelector:swizzledSelector
                            forClass:aClass];

    [self mzd_jskit_extension_jsInject_setNavigationDelegate:delegate];
}

- (void)mzd_jskit_extension_jsInject_default_webView:(WKWebView *)webView
                                 didFinishNavigation:(WKNavigation *)navigation {
}

- (void)mzd_jskit_extension_jsInject_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 注入 js
    if (!webView.mzd_jskit_jsURL) {
        if (webView.mzd_jskit_jsURLBlock) {
            webView.mzd_jskit_jsURL = webView.mzd_jskit_jsURLBlock(webView.URL);
        }
    }
    [webView mzd_jskit_evaluateJavaScriptWithURL:webView.mzd_jskit_jsURL
                               completionHandler:^(id o, NSError *error) {
                                   if (error) {
                                       JFLogError(@"evaluate js failed！%@", error);
                                   }
                               }];

    [self mzd_jskit_extension_jsInject_webView:webView didFinishNavigation:navigation];
}

- (NSURL *)mzd_jskit_jsURL {
    return objc_getAssociatedObject(self, &kJFWKWebViewProperty_jskit_extension_jsInject_jsURL);
}

- (void)setMzd_jskit_jsURL:(NSURL *)url {
    if (self.mzd_jskit_jsURL != url) {
        objc_setAssociatedObject(
            self, &kJFWKWebViewProperty_jskit_extension_jsInject_jsURL, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSURL * (^)(NSURL *))mzd_jskit_jsURLBlock {
    return objc_getAssociatedObject(self, &kJFWKWebViewProperty_jskit_extension_jsInject_jsURLBlock);
}

- (void)setMzd_jskit_jsURLBlock:(NSURL * (^)(NSURL *))block {
    if (self.mzd_jskit_jsURLBlock != block) {
        objc_setAssociatedObject(
            self, &kJFWKWebViewProperty_jskit_extension_jsInject_jsURLBlock, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

@end

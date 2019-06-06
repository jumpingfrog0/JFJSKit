//
//  WKWebView+JFJSKitPlugin_jsInject.m
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
#import "WKWebView+JFJSKitPlugin.h"
#import "WKWebView+JFJSKitPlugin_jsInject.h"
#import <objc/runtime.h>

static char kJFWKWebViewProperty_jskit_plugin_jsInject_jsURL;
static char kJFWKWebViewProperty_jskit_plugin_jsInject_jsURLBlock;

@implementation WKWebView (JFJSKitPlugin_jsInject)

+ (void)load {
    [self jf_jskit_plugin_jsInject_hookNavigationDelegate];
}

#pragma mark-- HookNaivationDelegate
+ (void)jf_jskit_plugin_jsInject_hookNavigationDelegate {
    SEL originalSelector = @selector(setNavigationDelegate:);
    SEL swizzledSelector = @selector(jf_jskit_plugin_jsInject_setNavigationDelegate:);

    [self jf_jskit_changeSelector:originalSelector withSelector:swizzledSelector];
}

- (void)jf_jskit_plugin_jsInject_setNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    Class aClass = [delegate class];

    SEL originalSelector = @selector(webView:didFinishNavigation:);
    SEL defaultSelector  = @selector(jf_jskit_plugin_jsInject_default_webView:didFinishNavigation:);
    SEL swizzledSelector = @selector(jf_jskit_plugin_jsInject_webView:didFinishNavigation:);
    [self jf_jskit_hookSelector:originalSelector
        withDefaultImplementSelector:defaultSelector
                    swizzledSelector:swizzledSelector
                            forClass:aClass];

    [self jf_jskit_plugin_jsInject_setNavigationDelegate:delegate];
}

- (void)jf_jskit_plugin_jsInject_default_webView:(WKWebView *)webView
                                 didFinishNavigation:(WKNavigation *)navigation {
}

- (void)jf_jskit_plugin_jsInject_webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // inject javascript
    if (!webView.jf_jskit_jsURL) {
        if (webView.jf_jskit_jsURLBlock) {
            webView.jf_jskit_jsURL = webView.jf_jskit_jsURLBlock(webView.URL);
        }
    }
    [webView jf_jskit_evaluateJavaScriptWithURL:webView.jf_jskit_jsURL
                               completionHandler:^(id o, NSError *error) {
                                   if (error) {
                                       JFLogError(@"evaluate js failed！%@", error);
                                   }
                               }];

    [self jf_jskit_plugin_jsInject_webView:webView didFinishNavigation:navigation];
}

- (NSURL *)jf_jskit_jsURL {
    return objc_getAssociatedObject(self, &kJFWKWebViewProperty_jskit_plugin_jsInject_jsURL);
}

- (void)setJf_jskit_jsURL:(NSURL *)url {
    if (self.jf_jskit_jsURL != url) {
        objc_setAssociatedObject(
            self, &kJFWKWebViewProperty_jskit_plugin_jsInject_jsURL, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (NSURL * (^)(NSURL *))jf_jskit_jsURLBlock {
    return objc_getAssociatedObject(self, &kJFWKWebViewProperty_jskit_plugin_jsInject_jsURLBlock);
}

- (void)setJf_jskit_jsURLBlock:(NSURL * (^)(NSURL *))block {
    if (self.jf_jskit_jsURLBlock != block) {
        objc_setAssociatedObject(
            self, &kJFWKWebViewProperty_jskit_plugin_jsInject_jsURLBlock, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

@end

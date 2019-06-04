//
//  JFJSAPIHistoryCleaner.m
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

#import "JFJSAPIHistoryCleaner.h"
#import "JFJSKitDefines.h"
#import "NSObject+JFJSKitAdditions.h"
#import <WebKit/WKBackForwardList.h>
#import <objc/runtime.h>

static char kJFWKWebViewProperty_jsapi_historyCleaner_clearIndex;

@interface WKWebView (JFJSAPIHistoryCleaner)

@property (nonatomic, assign) NSInteger mzd_jsapi_historyCleaner_clearIndex;

@end

@implementation WKWebView (JFJSAPIHistoryCleaner)

+ (void)load
{
    [self mzd_jsapi_historyCleaner_hookCanGoBack];
}

+ (void)mzd_jsapi_historyCleaner_hookCanGoBack
{
    SEL originalSelector = @selector(canGoBack);
    SEL swizzledSelector = @selector(mzd_jsapi_historyCleaner_canGoBack);
    [self mzd_jskit_changeSelector:originalSelector withSelector:swizzledSelector];
}

- (BOOL)mzd_jsapi_historyCleaner_canGoBack
{
    if (self.mzd_jsapi_historyCleaner_clearIndex > 0) {
        if (self.mzd_jsapi_historyCleaner_clearIndex >= self.backForwardList.backList.count) {
            return NO;
        }
    }

    return [self mzd_jsapi_historyCleaner_canGoBack];
}

- (NSInteger)mzd_jsapi_historyCleaner_clearIndex
{
    id clearIndex = objc_getAssociatedObject(self, &kJFWKWebViewProperty_jsapi_historyCleaner_clearIndex);
    return [clearIndex integerValue];
}

- (void)setMzd_jsapi_historyCleaner_clearIndex:(NSInteger)index
{
    if (self.mzd_jsapi_historyCleaner_clearIndex != index) {
        objc_setAssociatedObject(
            self, &kJFWKWebViewProperty_jsapi_historyCleaner_clearIndex, @(index), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end

@interface JFJSAPIHistoryCleaner ()

@end

@implementation JFJSAPIHistoryCleaner

+ (NSString *)command
{
    return @"clear_history";
}

- (void)webRunOnCompletion:(JFJSAPICompletionBlock)completion
{
    WKWebView *wv                          = (WKWebView *)self.request.view;
    wv.mzd_jsapi_historyCleaner_clearIndex = wv.backForwardList.backList.count;

    [self.request onSuccess:nil];

    if (completion) {
        completion();
    }
}

- (void)rctRunOnCompletion:(JFJSAPICompletionBlock)completion
{
    JFLogWarning(@"%@ 不支持 react-native", self.request.url);
}

@end

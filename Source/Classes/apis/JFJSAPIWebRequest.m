//
//  JFJSAPIWebRequest.m
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

#import "JFJSAPIWebRequest.h"
#import "JFJSKitDefines.h"
#import "NSDictionary+JFJSAPI.h"
#import "NSURL+JFJSAPI.h"
#import <WebKit/WKWebView.h>

@interface JFJSAPIWebRequest ()

@property (nonatomic, strong) NSDictionary *options;

@end

@implementation JFJSAPIWebRequest
@synthesize url            = _url;
@synthesize view           = _view;
@synthesize viewController = _viewController;

- (void)setUrl:(NSURL *)url
{
    if (_url != url) {
        _url = url;

        self.options = [url jf_jsapi_parameters];
    }
}

- (void)onSuccess:(NSDictionary *)result
{
    if (!result) {
        result = @{};
    }

    NSString *msg = [result jf_jsapi_jsSuccess];
    NSString *js  = [self.url jf_jsapi_jsEvaluationWith:msg];
    [self evaluateJavaScript:js];
}

- (void)onFailure:(NSDictionary *)result
{
    if (!result) {
        result = @{};
    }

    NSString *msg = [result jf_jsapi_jsError];
    NSString *js  = [self.url jf_jsapi_jsEvaluationWith:msg];
    [self evaluateJavaScript:js];
}

- (BOOL)canEvaluateJavaScript {
    return [self.view isKindOfClass:[WKWebView class]];
}

- (void)evaluateJavaScript:(NSString *)js {
    if (![self canEvaluateJavaScript]) {
        JFLogError(@"Evaluate js failed, because the container is not a WKWebView. Protocol: %@", self.url);
        return;
    }

    if (js.length <= 0) {
        JFLogError(@"Evaluate js failed. Javascript is empty. Protocol: %@", self.url);
        return;
    }

    WKWebView *wv = (WKWebView *)self.view;
    [wv evaluateJavaScript:js
         completionHandler:^(id s, NSError *error) {
             if (error) {
                 JFLogError(@"Evaluate js failed. js: %@ , error: %@", js, error);
             }
         }];
}

@end

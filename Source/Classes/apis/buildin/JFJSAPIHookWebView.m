//
//  JFJSAPIHookWebView.m
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

#import "JFJSAPIHookWebView.h"
#import "WKWebView+JFJSKitExtension.h"

@interface JFJSAPIHookWebView ()<WKNavigationDelegate>

@property (nonatomic, copy) JFJSAPICompletionBlock completion;

@property (nonatomic, strong) NSURL *jsURL;

@end

@implementation JFJSAPIHookWebView

+ (NSString *)command
{
    return @"open_background";
}

- (void)runOnCompletion:(JFJSAPICompletionBlock)completion
{
    self.completion = completion;

    NSURL *URL = [NSURL URLWithString:self.request.options[@"url"]];
    self.jsURL = [NSURL URLWithString:self.request.options[@"js_url"]];

    if (self.jsURL) {
        WKWebView *wv         = [[WKWebView alloc] initWithFrame:CGRectZero];
        wv.navigationDelegate = self;
        NSURLRequest *req     = [[NSURLRequest alloc] initWithURL:URL];
        [wv loadRequest:req];

        [self.request.view addSubview:wv];
    } else {
        [self.request onFailure:nil];
        if (completion) {
            completion();
        }
    }
}

#pragma mark--
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    __weak WKWebView *weakWV             = webView;
    __weak JFJSAPIHookWebView *weakSelf = self;
    [webView mzd_jskit_evaluateJavaScriptWithURL:self.jsURL
                               completionHandler:^(id o, NSError *error) {
                                   [weakWV removeFromSuperview];
                                   if (error) {
                                       [weakSelf.request onFailure:@{
                                           @"msg": error.localizedDescription,
                                           @"code": @(error.code),
                                       }];

                                       if (weakSelf.completion) {
                                           weakSelf.completion();
                                       }
                                   } else {
                                       [weakSelf.request onSuccess:nil];
                                       if (weakSelf.completion) {
                                           weakSelf.completion();
                                       }
                                   }
                               }];
}

@end

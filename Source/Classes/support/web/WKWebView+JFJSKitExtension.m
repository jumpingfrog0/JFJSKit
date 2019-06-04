//
//  WKWebView+JFJSKitExtension.m
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
#import "JFJSKitExtension.h"
#import "NSObject+JFJSKitAdditions.h"
#import "WKWebView+JFJSKitExtension.h"
#import <objc/runtime.h>

static char kJFWKWebViewProperty_jskit_extension;

@implementation WKWebView (JFJSKitExtension)
+ (void)load {
    [self mzd_jskit_extension_hookNavigationDelegate];
    [self mzd_jskit_extension_hookUIDelegate];
}
#pragma mark-- HookNaivationDelegate
+ (void)mzd_jskit_extension_hookNavigationDelegate {
    SEL originalSelector = @selector(setNavigationDelegate:);
    SEL swizzledSelector = @selector(mzd_jskit_extension_setNavigationDelegate:);

    [self mzd_jskit_changeSelector:originalSelector withSelector:swizzledSelector];
}

- (void)mzd_jskit_extension_setNavigationDelegate:(id<WKNavigationDelegate>)delegate {
    Class aClass = [delegate class];

    SEL originalSelector = @selector(webView:decidePolicyForNavigationAction:decisionHandler:);
    SEL defaultSelector =
        @selector(mzd_jskit_extension_default_webView:decidePolicyForNavigationAction:decisionHandler:);
    SEL swizzledSelector = @selector(mzd_jskit_extension_webView:decidePolicyForNavigationAction:decisionHandler:);
    [self mzd_jskit_hookSelector:originalSelector
        withDefaultImplementSelector:defaultSelector
                    swizzledSelector:swizzledSelector
                            forClass:aClass];

    originalSelector = @selector(webView:didReceiveAuthenticationChallenge:completionHandler:);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    defaultSelector =
        @selector(mzd_jskit_extension_default_webView:didReceiveAuthenticationChallenge:completionHandler:);
#pragma clang diagnostic pop

    swizzledSelector = @selector(mzd_jskit_extension_webView:didReceiveAuthenticationChallenge:completionHandler:);
    [self mzd_jskit_hookSelector:originalSelector
        withDefaultImplementSelector:defaultSelector
                    swizzledSelector:swizzledSelector
                            forClass:aClass];

    [self mzd_jskit_extension_setNavigationDelegate:delegate];
}

- (void)mzd_jskit_extension_webView:(WKWebView *)webView
    didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
                    completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition,
                                                NSURLCredential *credential))completionHandler {
    if (![challenge.protectionSpace.authenticationMethod isEqualToString:@"NSURLAuthenticationMethodServerTrust"]) {
        return;
    }
    // NSURLSessionAuthChallengeDisposition 如何处理证书
    /*
     NSURLSessionAuthChallengeUseCredential = 0, 使用该证书 安装该证书
     NSURLSessionAuthChallengePerformDefaultHandling = 1, 默认采用的方式,该证书被忽略
     NSURLSessionAuthChallengeCancelAuthenticationChallenge = 2, 取消请求,证书忽略
     NSURLSessionAuthChallengeRejectProtectionSpace = 3,          拒绝
     */
    NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];

    if (completionHandler) {
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}

- (void)mzd_jskit_extension_default_webView:(WKWebView *)webView
            decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                            decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (decisionHandler) {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)mzd_jskit_extension_webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    id sender = webView.navigationDelegate;

    if (webView.mzd_jskit_extension) {

        JFJSAPIWebRequest *jsApiRequest = [[JFJSAPIWebRequest alloc] init];
        jsApiRequest.url                 = navigationAction.request.URL;
        jsApiRequest.view                = webView;

        if ([sender isKindOfClass:UIViewController.class]) {
            jsApiRequest.viewController = sender;
        } else if ([webView.UIDelegate isKindOfClass:UIViewController.class]) {
            jsApiRequest.viewController = (UIViewController *)webView.UIDelegate;
        }
        BOOL handled = [webView.mzd_jskit_extension handleRequest:jsApiRequest];

        if (handled) {
            if (decisionHandler) {
                decisionHandler(WKNavigationActionPolicyCancel);
            }
            return;
        }
    }

    SEL sel            = @selector(mzd_jskit_extension_webView:decidePolicyForNavigationAction:decisionHandler:);
    NSArray *arguments = @[
        webView ?: [NSNull null],
        navigationAction ?: [NSNull null],
        decisionHandler,
    ];
    [sender mzd_jskit_performSelector:sel withObjects:arguments];
}

#pragma mark-- HookUIDelegate
+ (void)mzd_jskit_extension_hookUIDelegate {
    SEL originalSelector = @selector(setUIDelegate:);
    SEL swizzledSelector = @selector(mzd_jskit_extension_setUIDelegate:);

    [self mzd_jskit_changeSelector:originalSelector withSelector:swizzledSelector];
}

- (void)mzd_jskit_extension_setUIDelegate:(id<WKUIDelegate>)delegate {
    Class aClass = [delegate class];
    SEL originalSelector =
        @selector(webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame:completionHandler:);
    SEL defaultSelector =
        @selector(mzd_jskit_extension_default_webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame
                                                     :completionHandler:);
    SEL swizzledSelector = @selector(mzd_jskit_extension_webView:runJavaScriptTextInputPanelWithPrompt:defaultText
                                                                :initiatedByFrame:completionHandler:);

    [self mzd_jskit_hookSelector:originalSelector
        withDefaultImplementSelector:defaultSelector
                    swizzledSelector:swizzledSelector
                            forClass:aClass];

    [self mzd_jskit_extension_setUIDelegate:delegate];
}

- (void)mzd_jskit_extension_default_webView:(WKWebView *)webView
      runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
                                defaultText:(NSString *)defaultText
                           initiatedByFrame:(WKFrameInfo *)frame
                          completionHandler:(void (^)(NSString *result))completionHandler {
    if (completionHandler) {
        completionHandler(@"");
    }
}

- (void)mzd_jskit_extension_webView:(WKWebView *)webView
    runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
                              defaultText:(NSString *)defaultText
                         initiatedByFrame:(WKFrameInfo *)frame
                        completionHandler:(void (^)(NSString *result))completionHandler {
    id sender = webView.UIDelegate;

    if (webView.mzd_jskit_extension) {
        JFJSAPIWebRequest *jsApiRequest = [[JFJSAPIWebRequest alloc] init];
        jsApiRequest.url                 = [NSURL URLWithString:prompt];
        jsApiRequest.view                = webView;

        if ([sender isKindOfClass:UIViewController.class]) {
            jsApiRequest.viewController = sender;
        } else if ([webView.navigationDelegate isKindOfClass:UIViewController.class]) {
            jsApiRequest.viewController = (UIViewController *)webView.navigationDelegate;
        }
        BOOL handled = [webView.mzd_jskit_extension handleRequest:jsApiRequest];

        if (handled) {
            if (completionHandler) {
                completionHandler(@"");
            }
            return;
        }
    }

    SEL sel = @selector(mzd_jskit_extension_webView:runJavaScriptTextInputPanelWithPrompt:defaultText:initiatedByFrame
                                                   :completionHandler:);
    NSArray *arguments = @[
        webView ?: [NSNull null],
        prompt ?: [NSNull null],
        defaultText ?: [NSNull null],
        frame ?: [NSNull null],
        completionHandler,
    ];
    [sender mzd_jskit_performSelector:sel withObjects:arguments];
}

#pragma mark--
- (JFJSKitExtension *)mzd_jskit_extension {
    return objc_getAssociatedObject(self, &kJFWKWebViewProperty_jskit_extension);
}

- (void)setMzd_jskit_extension:(JFJSKitExtension *)extension {
    if (self.mzd_jskit_extension != extension) {
        objc_setAssociatedObject(
            self, &kJFWKWebViewProperty_jskit_extension, extension, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)mzd_jskit_addCustomUserAgent:(NSString *)userAgent {
    if ([self respondsToSelector:@selector(customUserAgent)]) {
        if (userAgent.length > 0) {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSString *ua       = [ud objectForKey:@"UserAgent"];
            BOOL exist         = [ua rangeOfString:userAgent].length > 0;
            if (!exist) {
                ua                   = [NSString stringWithFormat:@"%@ %@", ua, userAgent];
                self.customUserAgent = ua;
            }
        }
    }
}

- (void)mzd_jskit_evaluateJavaScriptWithURL:(NSURL *)url
                          completionHandler:(void (^)(id result, NSError *error))handler {
    if (url) {
        __weak WKWebView *weakSelf = self;
        [self mzd_jskit_getJavaScriptWithURL:url
                                  completion:^(NSString *string) {
                                      [weakSelf evaluateJavaScript:string completionHandler:handler];
                                  }];
    }
}

- (void)mzd_jskit_getJavaScriptWithURL:(NSURL *)url completion:(void (^)(NSString *))completion {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *req     = [NSURLRequest requestWithURL:url];
    NSURLSessionDownloadTask *task;
    task = [session
        downloadTaskWithRequest:req
              completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                  if (!error) {
                      if (completion) {
                          NSString *js =
                              [NSString stringWithContentsOfURL:location encoding:NSUTF8StringEncoding error:nil];
                          dispatch_async(dispatch_get_main_queue(), ^{
                              completion(js);
                          });
                      }
                  }
              }];

    [task resume];
}

@end

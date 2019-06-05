//
//  JFJSAPIService.m
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

#import "JFJSAPIService.h"
#import "JFJSAPIChangeTitle.h"
#import "JFJSAPICopyToClipboard.h"
#import "JFJSAPIHistoryCleaner.h"
#import "JFJSAPIHookWebView.h"
#import "JFJSAPILocation.h"
#import "JFJSAPIOpenBrowser.h"
#import "JFJSAPIOpenURL.h"
#import "JFJSAPITerminate.h"
#import "JFJSKitDefines.h"

@interface JFJSAPIService ()

@property (nonatomic, strong) NSMutableDictionary *apis;
@property (nonatomic, strong) NSMutableDictionary *httpApis;
@property (nonatomic, strong) NSMutableArray *activeApis;

@end

@implementation JFJSAPIService

- (instancetype)init {
    if (self = [super init]) {
        self.apis = [NSMutableDictionary dictionary];
        self.httpApis = [NSMutableDictionary dictionary];
        self.activeApis = [NSMutableArray array];

        NSArray *apisClass = @[
                JFJSAPICopyToClipboard.class,
                JFJSAPIHistoryCleaner.class,
                JFJSAPIHookWebView.class,
                JFJSAPILocation.class,
                JFJSAPIOpenBrowser.class,
                JFJSAPIOpenURL.class,
                JFJSAPITerminate.class,
                JFJSAPIChangeTitle.class
        ];
        [apisClass enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Class <JFJSAPIProtocol> aClass = obj;
            [self registerApi:aClass];
        }];
    }
    return self;
}

- (void)registerApi:(Class <JFJSAPIProtocol>)api {
    if ([api conformsToProtocol:@protocol(JFJSAPIProtocol)]) {
        NSString *command = [api command];
        self.apis[command] = api;

        if ([api respondsToSelector:@selector(httpCommands)]) {
            NSArray *httpCommands = [api httpCommands];
            [httpCommands enumerateObjectsUsingBlock:^(NSString *httpCommand, NSUInteger idx, BOOL *stop) {
                if (![httpCommand isKindOfClass:NSString.class]) {
                    JFLogError(@"Can not register plugin: %@, httpCommands must be a NSString array", NSStringFromClass(api.class));
                    *stop = YES;
                    return;
                }

                self.httpApis[httpCommand] = api;
            }];
        }
    } else {
        JFLogWarning(@"Can not register plugin: %@, because it is not supported", NSStringFromClass(api.class));
    }
}

- (void)unregisterApi:(Class <JFJSAPIProtocol>)api {
    if ([api conformsToProtocol:@protocol(JFJSAPIProtocol)]) {
        NSString *command = [api command];
        [self.apis removeObjectForKey:command];

        if ([api respondsToSelector:@selector(httpCommands)]) {
            NSArray *httpCommands = [api httpCommands];
            [httpCommands enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
                [self.httpApis removeObjectForKey:obj];
            }];
        }
    } else {
        JFLogWarning(@"can not unregister plugin: %@, because it is not supported", NSStringFromClass(api.class));
    }
}


#pragma mark--

- (id <JFJSAPIProtocol>)searchApi:(NSString *)command {
    Class apiClass = self.apis[command];
    if (!apiClass) {
        apiClass = self.httpApis[command];
    }

    if (apiClass) {
        return [[apiClass alloc] init];
    }
    return nil;
}

#pragma mark--

- (BOOL)sendRequest:(id <JFJSAPIRequestProtocol>)request {
    // todo: should append with host?
    NSString *key = [request.url.host stringByAppendingPathComponent:request.url.path];
    id <JFJSAPIProtocol> api = [self searchApi:key];
    if (api) {
        api.request = request;
        // api task might be asynchronous, we need to hold the reference of api object before task completed.
        [self.activeApis addObject:api];

        __weak typeof(self) weakSelf = self;
        __weak id <JFJSAPIProtocol> weakApi = api;
        [api runOnCompletion:^{
            // release active api object after task completed
            [weakSelf.activeApis performSelector:@selector(removeObject:) withObject:weakApi afterDelay:1];
        }];

        return YES;
    }
    return NO;
}

@end

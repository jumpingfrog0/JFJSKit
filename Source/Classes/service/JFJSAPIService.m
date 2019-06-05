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
#import "NSDictionary+JFJSAPI.h"
#import "NSURL+JFJSAPI.h"

@interface JFJSAPIService ()

@property (nonatomic, strong) NSMutableDictionary *apis;
@property (nonatomic, strong) NSMutableDictionary *httpApis;
@property (nonatomic, strong) NSMutableArray *activeApi;

@end

@implementation JFJSAPIService

- (instancetype)init
{
    if (self = [super init]) {
        self.apis      = [NSMutableDictionary dictionary];
        self.httpApis  = [NSMutableDictionary dictionary];
        self.activeApi = [NSMutableArray array];

        NSArray *apisClass = @[
            JFJSAPICopyToClipboard.class,
            JFJSAPIHistoryCleaner.class,
            JFJSAPIHookWebView.class,
            JFJSAPILocation.class,
            JFJSAPIOpenBrowser.class,
            JFJSAPIOpenURL.class,
            JFJSAPITerminate.class,
            JFJSAPIChangeTitle.class,
        ];
        [apisClass enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            Class<JFJSAPIProtocol> aClass = obj;
            [self registerApi:aClass];
        }];
    }
    return self;
}

- (void)registerApi:(Class<JFJSAPIProtocol>)api
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    if ([api conformsToProtocol:@protocol(JFJSAPIProtocol)]) {
        NSString *command  = [api command];
        self.apis[command] = api;

        if ([api respondsToSelector:@selector(httpCommands)]) {
            NSArray *httpCommands = [api httpCommands];
            [httpCommands enumerateObjectsUsingBlock:^(NSString *obj1, NSUInteger idx1, BOOL *stop1) {
                self.httpApis[obj1] = api;
            }];
        }
    } else {
        JFLogWarning(@"can not register %@ plugin, because it is not supported", NSStringFromClass(api.class));
    }
#pragma clang diagnostic pop
}

- (void)unregisterApi:(Class<JFJSAPIProtocol>)api
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    if ([api conformsToProtocol:@protocol(JFJSAPIProtocol)]) {
        NSString *command  = [api command];
        self.apis[command] = nil;

        if ([api respondsToSelector:@selector(httpCommands)]) {
            NSArray *httpCommands = [api httpCommands];
            [httpCommands enumerateObjectsUsingBlock:^(NSString *obj1, NSUInteger idx1, BOOL *stop1) {
                self.httpApis[obj1] = nil;
            }];
        }
    } else {
        JFLogWarning(@"can not unregister %@ plugin, because it is not supported", NSStringFromClass(api.class));
    }
#pragma clang diagnostic pop
}


#pragma mark--
- (id<JFJSAPIProtocol>)searchApi:(NSString *)command
{
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
- (BOOL)testRequest:(id<JFJSAPIRequestProtocol>)request
{
    NSString *key = [request.url.host stringByAppendingPathComponent:request.url.path];
    id<JFJSAPIProtocol> api = [self searchApi:key];
    if (api) {
        api.request = request;
        // api 任务可能是异步，需要在任务完成之前勾住 plugin 对象
        // api 执行完成后释放
        [self.activeApi addObject:api];

        __weak typeof(self) weakSelf        = self;
        __weak id<JFJSAPIProtocol> weakApi = api;

        [api runOnCompletion:^{
            [weakSelf.activeApi performSelector:@selector(removeObject:) withObject:weakApi afterDelay:1];
        }];

        return YES;
    }
    return NO;
}

@end

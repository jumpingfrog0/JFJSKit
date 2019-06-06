//
//  JFJSAPIBase.m
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

#import "JFJSAPIBase.h"
#import "JFJSAPIRCTRequest.h"
#import "JFJSAPIWebRequest.h"
#import "JFJSKitDefines.h"

@interface JFJSAPIBase ()

@end

@implementation JFJSAPIBase
@synthesize request = _request;

+ (NSString *)command
{
    return nil;
}

- (void)runOnCompletion:(JFJSAPICompletionBlock)completion
{
    if ([self.request isKindOfClass:JFJSAPIWebRequest.class]) {
        if ([self respondsToSelector:@selector(webRunOnCompletion:)]) {
            [self webRunOnCompletion:completion];
        }
    } else if ([self.request isKindOfClass:JFJSAPIRCTRequest.class]) {
        if ([self respondsToSelector:@selector(rctRunOnCompletion:)]) {
            [self rctRunOnCompletion:completion];
        }
    } else {
        [self apiRunOnCompletion:completion];
    }
}

- (void)apiRunOnCompletion:(JFJSAPICompletionBlock)completion {
    JFLogWarning(@"The request should be neither `JFJSAPIWebRequest` nor `JFJSAPIRCTRequest`");
    [self.request onFailure:nil];
    if (completion) {
        completion();
    }
}

- (void)webRunOnCompletion:(JFJSAPICompletionBlock)completion {
    JFLogWarning(@"You maybe forget to implement `webRunOnCompletion:`");
    [self.request onFailure:nil];
    if (completion) {
        completion();
    }
}

- (void)rctRunOnCompletion:(JFJSAPICompletionBlock)completion {
    JFLogWarning(@"You maybe forget to implement `rctRunOnCompletion:`");
    [self.request onFailure:nil];
    if (completion) {
        completion();
    }
}


@end

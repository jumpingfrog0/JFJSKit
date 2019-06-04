//
//  NSURL+JFJSAPIService.m
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

#import "NSString+JFJSKitAdditions.h"
#import "NSURL+JFJSAPIService.h"
#import "NSURL+JFJSKitAdditions.h"

@implementation NSURL (JFJSAPIService)

- (NSString *)mzd_jsapi_jsEvaluationWith:(NSString *)msg
{
    NSString *jsFunction = [self mzd_jsapi_callback];
    NSString *jsFlag     = [self mzd_jsapi_flag];
    if (jsFunction && jsFlag) {
        return [NSString stringWithFormat:@"javascript:%@(\"%@\", \"%@\")", jsFunction, jsFlag, msg];
    }
    return nil;
}

- (NSDictionary *)mzd_jsapi_parameters
{
    NSString *json = [self mzd_jskit_parameters][@"params"];
    json           = [json mzd_jskit_stringByUnescapingFromURLArgument];
    return [json mzd_jskit_JSONObject];
}

- (NSString *)mzd_jsapi_callback
{
    return [self mzd_jskit_parameters][@"callback"];
}

- (NSString *)mzd_jsapi_flag
{
    return [self mzd_jskit_parameters][@"flag"];
}

@end

//
//  NSDictionary+JFJSAPIService.m
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

#import "NSDictionary+JFJSAPI.h"
#import "NSString+JFJSKitAdditions.h"

@implementation NSDictionary (JFJSAPI)

- (NSString *)jf_jsapi_jsSuccess
{
    NSDictionary *result;
    if (self.allKeys.count > 0) {
        result = @{
            @"success": @(YES),
            @"data": self,
        };
    } else {
        result = @{
            @"success": @(YES),
        };
    }

    NSString *msg = [NSString jf_jskit_stringWithJSONObject:result];
    msg           = [msg jf_jskit_stringByEscapingForURLArgument];
    return msg;
}

- (NSString *)jf_jsapi_jsError
{
    NSDictionary *result = @{
        @"success": @(NO),
        @"error": self,
    };

    NSString *msg = [NSString jf_jskit_stringWithJSONObject:result];
    msg           = [msg jf_jskit_stringByEscapingForURLArgument];
    return msg;
}

@end

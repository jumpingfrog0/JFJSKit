//
//  NSURL+JFJSKitAdditions.m
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

#import "NSDictionary+JFJSKitAdditions.h"
#import "NSURL+JFJSKitAdditions.h"

@implementation NSURL (JFJSKitAdditions)

- (NSDictionary *)mzd_jskit_parameters
{
    NSString *parametersString = self.query;
    NSArray *array             = [parametersString componentsSeparatedByString:@"&"];
    if (array.count > 0) {
        NSMutableDictionary *parametersDic = [NSMutableDictionary dictionary];
        __block NSArray *kvArray           = nil;
        [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
            kvArray = [obj componentsSeparatedByString:@"="];
            if (kvArray.count != 2) {
                NSLog(@"Warning: URL parse parameter:%@ -- error: parameters should like key1=value1&key2=value2 "
                      @"followed by URL path...",
                      obj);
            } else {
                parametersDic[kvArray[0]] = kvArray[1];
            }
        }];
        return parametersDic;
    }
    return nil;
}

- (NSURL *)mzd_jskit_URLByAddQueriesFromDictionary:(NSDictionary *)dictionary
{
    NSString *query = [dictionary mzd_jskit_joinURLQueries];
    if (query.length > 0) {
        NSURLComponents *comp = [NSURLComponents componentsWithURL:self resolvingAgainstBaseURL:YES];
        if (comp.query.length > 0) {
            comp.query = [comp.query stringByAppendingString:[NSString stringWithFormat:@"&%@", query]];
        } else {
            comp.query = [query copy];
        }
        return [comp URL];
    }

    return self;
}

@end

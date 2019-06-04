//
//  NSString+JFJSKitAdditions.m
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
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (JFJSKitAdditions)

- (id)mzd_jskit_JSONObject
{
    if (!self) {
        return nil;
    }

    NSData *data   = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id jsonObject  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];

    if (error) {
//        NSException *e =
//            [NSException exceptionWithName:@"JF JSONParser Error" reason:error.localizedDescription userInfo:nil];
//        [e raise];
        return nil;
    }

    return jsonObject;
}

+ (NSString *)mzd_jskit_stringWithJSONObject:(id)object
{
    if (!self) {
        return nil;
    }

    NSError *error   = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];

    if (error) {
        NSException *e =
            [NSException exceptionWithName:@"JF JSONParser Error" reason:error.localizedDescription userInfo:nil];
        [e raise];
    }

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)mzd_jskit_stringByEscapingForURLArgument
{

    // Encode all the reserved characters, per RFC 3986
    // (<http://www.ietf.org/rfc/rfc3986.txt>)
    NSMutableCharacterSet *set = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [set removeCharactersInString:@"!*'();:@&=+$,/?%#[]"];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:set];
}

- (NSString *)mzd_jskit_stringByUnescapingFromURLArgument
{
    NSMutableString *resultString = [NSMutableString stringWithString:self];
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    return [resultString stringByRemovingPercentEncoding];
}

- (NSString *)mzd_jskit_md5
{

    if (self == nil || [self length] == 0) return nil;

    const char *value = [self UTF8String];

    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);

    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++) {
        [outputString appendFormat:@"%02x", outputBuffer[count]];
    }

    return outputString;
}


@end

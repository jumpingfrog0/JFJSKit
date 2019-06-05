//
//  JFJSKitPluginConfig.h
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


#import <Foundation/Foundation.h>

@interface JFJSKitPluginConfig : NSObject

/**
 * The header of protocol allowed among native client, webview and react-native.
 */
@property (nonatomic, copy) NSSet<NSString *> *allowSchemes;

/**
 * The schemes that allow to open url.
 *
 * By default, The WKWebView injected with jskit plugin is not allowed to open URLScheme. It's mean that you can not open other external app.
 * Adding some URLSchemes to whitelist for allowing to open external url by setting `openURLSchemes`.
 *
 * such as: @{ @"scheme" : @(YES) }
 */
@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *openURLSchemes;

@end

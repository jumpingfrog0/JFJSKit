//
//  NSObject+JFJSKitAdditions.m
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

#import "NSObject+JFJSKitAdditions.h"
#import <objc/runtime.h>


@implementation NSObject (JFJSKitAdditions)
- (void)jf_jskit_hookSelector:(SEL)originalSelector
 withDefaultImplementSelector:(SEL)defaultSelector
             swizzledSelector:(SEL)swizzledSelector
                     forClass:(Class)aClass; {
    Method defaultMethod = class_getInstanceMethod(self.class, defaultSelector);
    Method swizzledMethod = class_getInstanceMethod(self.class, swizzledSelector);

    BOOL result;
    if (![aClass instancesRespondToSelector:originalSelector]) {
        result = class_addMethod(
                aClass, originalSelector, method_getImplementation(defaultMethod), method_getTypeEncoding(defaultMethod));
    }
    Method originalMethod = class_getInstanceMethod(aClass, originalSelector);

    if (![aClass instancesRespondToSelector:swizzledSelector]) {
        result = class_addMethod(aClass, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    } else {
        result = NO;
    }

    if (result) {
        swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);

        result = class_addMethod(
                aClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (result) {
            class_replaceMethod(aClass,
                    swizzledSelector,
                    method_getImplementation(originalMethod),
                    method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
}

+ (void)jf_jskit_changeSelector:(SEL)sel withSelector:(SEL)swizzledSel {
    Method originalMethod = class_getInstanceMethod(self, sel);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSel);

    BOOL result =
            class_addMethod(self, sel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));

    if (result) {
        class_replaceMethod(
                self, swizzledSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (id)jf_jskit_performSelector:(SEL)sel withObjects:(NSArray *)objects {
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:sel];
    if (signature == nil) {
        return nil;
    }

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = sel;

    // setting arguments
    NSInteger paramsCount = signature.numberOfArguments - 2; // except the arguments: self, _cmd
    paramsCount = MIN(paramsCount, objects.count);

    for (NSInteger i = 0; i < paramsCount; i++) {
        id object = objects[i];
        if ([object isKindOfClass:[NSNull class]]) continue;
        [invocation setArgument:&object atIndex:i + 2];
    }

    [invocation invoke];

    const char *returnType = signature.methodReturnType;
    id returnValue;

    if (!strcmp(returnType, @encode(void))) {
        // If return type is void, then that is no return value
        returnValue = nil;
    } else if (!strcmp(returnType, @encode(id))) {
        // If return type is object, then set value for variable
        [invocation getReturnValue:&returnValue];
    } else {
        // If return type is basic type(NSInteger, BOOL, Double)
        // get return length
        NSUInteger length = signature.methodReturnLength;

        // apply memory according to length
        void *buffer = (void *) malloc(length);

        // set value
        [invocation getReturnValue:buffer];

        if (!strcmp(returnType, @encode(BOOL))) {
            returnValue = @(*((BOOL *) buffer));
        } else if (!strcmp(returnType, @encode(NSInteger))) {
            returnValue = @(*((NSInteger *) buffer));
        } else {
            returnValue = [NSValue valueWithBytes:buffer objCType:returnType];
        }
    }

    return returnValue;
}


@end

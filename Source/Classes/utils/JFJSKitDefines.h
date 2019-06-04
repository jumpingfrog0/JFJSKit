//
//  JFJSKitDefines.h
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


#ifndef JFJSKitDefines_h
#define JFJSKitDefines_h

#ifdef DEBUG
#define JFLogS(...) NSLog(__VA_ARGS__)
#define JFLogM() NSLog(@"%d : [%@ %s]", __LINE__, self.class, sel_getName(_cmd))

#define JFLog(frmt, ...) JFLogS((@"[JUD] " frmt), ##__VA_ARGS__)
#define JFLogSuccess(frmt, ...) JFLogS((@"✅[JUD] " frmt), ##__VA_ARGS__)
#define JFLogWarning(frmt, ...) JFLogS((@"⚡[JUD] " frmt), ##__VA_ARGS__)
#define JFLogError(frmt, ...) JFLogS((@"❌[JUD] " frmt), ##__VA_ARGS__)

#else
#define JFLogS(...)
#define JFLogM()

#define JFLog(frmt, ...)
#define JFLogSuccess(frmt, ...)
#define JFLogWarning(frmt, ...)
#define JFLogError(frmt, ...)
#endif


#endif /* JFJSKitDefines_h */

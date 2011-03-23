//
//  OnkurController.h
//  Bangla - Onkur
//
//  Created by S. M. Raiyan Kabir on 23/01/2011.
//

/*
 The MIT License
 
 Copyright (c) 2011 S. M. Raiyan Kabir
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

@class BanglaPhoneticEngine;
@class RKCandidate;

enum {
	RKUpward = 1,
	RKDownward = 2
};
typedef NSInteger RKCandidateDirection;

@interface OnkurController : IMKInputController {

	BanglaPhoneticEngine		*banglaEngine;
	RKCandidate					*rkCandidate;
	id							client;
	
	NSMutableString				*originalBuffer;
	
	NSMutableString				*previousText;
	BOOL						previousTextSet;
	NSRange						cursorPositionRange;
	NSMutableString				*intermediateDisplayString;
	
	NSMutableArray				*convertBufferArray;
	
	NSMutableArray				*hintArray;
	NSMutableArray				*hintPositionArray;
	
	NSSet						*alphaKeySet;
	
	BOOL						showCandidate;
	BOOL						converting;
	
	BOOL						usingBangla;
	
	
}

- (void) initEngine;

-(BOOL)handleEvent:(NSEvent*)event client:(id)sender;

- (NSArray *) composedStringArray:(id)sender;
- (NSString *) originalString:(id)sender;

- (void) convertText;

- (void) changeSelectionInDirection:(RKCandidateDirection) direction;
- (void) deleteLast;
- (NSPoint) cursorPosition;

- (BOOL) alphaKeyCode:(NSInteger) keyCode;

- (void) reset;

@end
